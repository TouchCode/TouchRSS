//
//  CFeedFetcher.m
//  TouchCode
//
//  Created by Jonathan Wight on 10/5/08.
//  Copyright 2008 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "CFeedFetcher.h"

#import "CFeedStore.h"
#import "CManagedURLConnection.h"
#import "CRSSFeedDeserializer.h"
#import "CFeed.h"
#import "CFeedEntry.h"
#import "CObjectTranscoder.h"
#import "CURLConnectionManager.h"
#import "CURLConnectionManagerChannel.h"
#import "NSManagedObjectContext_Extensions.h"
#import "CXMLElement.h"

@interface CFeedFetcher ()
@property (readwrite, nonatomic, assign) CFeedStore *feedStore;
@property (readwrite, nonatomic, assign) NSTimer *fetchTimer;
@property (readwrite, nonatomic, retain) NSMutableSet *currentURLs;
@end

#pragma mark -

@implementation CFeedFetcher

@synthesize feedStore;
@synthesize delegate;
@synthesize fetchInterval;
@synthesize fetchTimer;
@synthesize currentURLs;

- (id)initWithFeedStore:(CFeedStore *)inFeedStore;
{
if ((self = [super init]) != NULL)
	{
	self.feedStore = inFeedStore;
	self.fetchInterval = 2 * 60;
	self.currentURLs = [NSMutableSet set];
	}
return(self);
}

- (void)dealloc
{
[self cancel];

self.feedStore = NULL;
self.delegate = NULL;
self.currentURLs = NULL;
//
[super dealloc];
}

#pragma mark -

- (CRSSFeedDeserializer *)deserializerForData:(NSData *)inData
{
return([[[CRSSFeedDeserializer alloc] initWithData:inData] autorelease]);
}

- (CFeed *)subscribeToURL:(NSURL *)inURL error:(NSError **)outError
{
NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"URL == %@", inURL.absoluteString];
NSError *theError = NULL;;
BOOL theWasCreatedFlag = NO;
CFeed *theFeed = [self.feedStore.managedObjectContext fetchObjectOfEntityForName:[CFeed entityName] predicate:thePredicate createIfNotFound:YES wasCreated:&theWasCreatedFlag error:&theError];
if (theWasCreatedFlag == YES)
	{
	theFeed.URL = inURL.absoluteString;
	}

[self updateFeed:theFeed];

return(theFeed);
}

- (BOOL)updateFeed:(CFeed *)inFeed
{
return([self updateFeed:inFeed completionTicket:NULL]);
}

- (BOOL)updateFeed:(CFeed *)inFeed completionTicket:(CCompletionTicket *)inCompletionTicket
{
NSDate *theLastChecked = inFeed.lastChecked;
if (theLastChecked != NULL)
	{
	NSDate *theDate = [NSDate date];

	NSTimeInterval theInterval = [theDate timeIntervalSinceDate:theLastChecked];
	if (theInterval <= self.fetchInterval)
		return(NO);
	}

NSURL *theURL = [NSURL URLWithString:inFeed.URL];

if ([self.currentURLs containsObject:theURL] == YES)
	{
	NSLog(@"Already fetching %@, ignoring this request to update.", theURL);
	return(NO);
	}

[inCompletionTicket didBeginForTarget:self];

NSURLRequest *theRequest = [[[NSURLRequest alloc] initWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0] autorelease];
CCompletionTicket *theCompletionTicket = [CCompletionTicket completionTicketWithIdentifier:@"Update Feed" delegate:self userInfo:NULL subTicket:inCompletionTicket];

[self.currentURLs addObject:theURL];

CManagedURLConnection *theConnection = [[[CManagedURLConnection alloc] initWithRequest:theRequest completionTicket:theCompletionTicket] autorelease];
[[CURLConnectionManager instance] addAutomaticURLConnection:theConnection toChannel:@"RSS"];

return(YES);
}

- (void)cancel
{
[[[CURLConnectionManager instance] channelForName:@"RSS"] cancelAll:YES];
}

#pragma mark -

- (void)completionTicket:(CCompletionTicket *)inCompletionTicket didCompleteForTarget:(id)inTarget result:(id)inResult
{
NSError *theError = NULL;
CFeed *theFeed = NULL;

CManagedURLConnection *theConnection = (CManagedURLConnection *)inTarget;
[self.currentURLs removeObject:theConnection.request.URL];
CRSSFeedDeserializer *theDeserializer = [self deserializerForData:theConnection.data];
for (id theDictionary in theDeserializer)
	{
	if (theDeserializer.error != NULL)
		{
		NSLog(@"ERROR: bailing.");
		break;
		}

	ERSSFeedDictinaryType theType = [[theDictionary objectForKey:@"type"] intValue];
	switch (theType)
		{
		case FeedDictionaryType_Feed:
			{
			NSURL *theFeedURL = theConnection.request.URL;
			NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"URL == %@", theFeedURL.absoluteString];
			theFeed = [self.feedStore.managedObjectContext fetchObjectOfEntityForName:[CFeed entityName] predicate:thePredicate createIfNotFound:YES wasCreated:NULL error:&theError];

			CObjectTranscoder *theTranscoder = [[theFeed class] objectTranscoder];

			NSDictionary *theUpdateDictonary = [theTranscoder dictionaryForObjectUpdate:theFeed withPropertiesInDictionary:theDictionary error:&theError];
			if (theUpdateDictonary == NULL)
				{
				[NSException raise:NSGenericException format:@"dictionaryForObjectUpdate failed: %@", theError];
				}

			if ([[[theFeed class] objectTranscoder] updateObject:theFeed withPropertiesInDictionary:theUpdateDictonary error:&theError] == NO)
				{
				[NSException raise:NSGenericException format:@"Update Object failed: %@", theError];
				}

			theFeed.lastChecked = [NSDate date];
			}
			break;
		case FeedDictinaryType_Entry:
			{
			NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"identifier == %@", [theDictionary objectForKey:@"identifier"]];

			BOOL theWasCreatedFlag = NO;
			CFeedEntry *theEntry = [self.feedStore.managedObjectContext fetchObjectOfEntityForName:[CFeedEntry entityName] predicate:thePredicate createIfNotFound:YES wasCreated:&theWasCreatedFlag error:&theError];

			NSError *theError = NULL;
			CObjectTranscoder *theTranscoder = [[theEntry class] objectTranscoder];
			NSDictionary *theUpdateDictonary = [theTranscoder dictionaryForObjectUpdate:theEntry withPropertiesInDictionary:theDictionary error:&theError];
			if (theUpdateDictonary == NULL)
				{
				[NSException raise:NSGenericException format:@"dictionaryForObjectUpdate failed: %@", theError];
				}

			if ([theTranscoder updateObject:theEntry withPropertiesInDictionary:theUpdateDictonary error:&theError] == NO)
				{
				[NSException raise:NSGenericException format:@"Update Object failed: %@", theError];
				}

			theEntry.feed = theFeed;
			}
			break;
		}
	}

if (theDeserializer.error != NULL)
	{
	NSLog(@"CFeedStore got an error: %@", theDeserializer.error);

	if (self.delegate && [self.delegate respondsToSelector:@selector(feedFetcher:didFail:)])
		[self.delegate feedFetcher:self didFailFetchingFeed:theFeed withError:theDeserializer.error];

	if (inCompletionTicket.subTicket)
		[inCompletionTicket.subTicket didFailForTarget:self error:theDeserializer.error];
	}
else
	{
	if (self.delegate && [self.delegate respondsToSelector:@selector(feedFetcher:didFetchFeed:)])
		[self.delegate feedFetcher:self didFetchFeed:theFeed];

	if (inCompletionTicket.subTicket)
		[inCompletionTicket.subTicket didCompleteForTarget:self result:theFeed];
	}
	
[self.feedStore save];
}

- (void)completionTicket:(CCompletionTicket *)inCompletionTicket didFailForTarget:(id)inTarget error:(NSError *)inError
{
NSLog(@"CFeedstore got an error: %@", inError);

CManagedURLConnection *theConnection = (CManagedURLConnection *)inTarget;
[self.currentURLs removeObject:theConnection.request.URL];

if (inCompletionTicket.subTicket)
	[inCompletionTicket.subTicket didFailForTarget:self error:inError];
}

- (void)completionTicket:(CCompletionTicket *)inCompletionTicket didCancelForTarget:(id)inTarget
{
}

@end
