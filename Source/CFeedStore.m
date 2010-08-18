//
//  CFeedStore.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/8/08.
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

#import "CFeedStore.h"

#import "CFeedFetcher.h"
#import "CFeed.h"

#import "NSManagedObjectContext_Extensions.h"

static CFeedStore *gInstance = NULL;

@interface CFeedStore ()
@property (readwrite, nonatomic, retain) CFeedFetcher *feedFetcher;
@end

@implementation CFeedStore

@synthesize feedFetcher;

+ (Class)feedFetcherClass
{
return([CFeedFetcher class]);
}

+ (CFeedStore *)instance
{
if (gInstance == NULL)
	{
	gInstance = [[self alloc] init];
	}
return(gInstance);
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	self.name = @"TouchRSS";
	
	self.feedFetcher = [[[[[self class] feedFetcherClass] alloc] initWithFeedStore:self] autorelease];
	}
return(self);
}

- (void)dealloc
{
self.feedFetcher = NULL;
//
[super dealloc];
}

#pragma mark -

- (CFeed *)feedForURL:(NSURL *)inURL fetch:(BOOL)inFetchFlag
{
NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"URL == %@", inURL.absoluteString];
NSError *theError = NULL;;
BOOL theWasCreatedFlag = NO;
CFeed *theFeed = [self.managedObjectContext fetchObjectOfEntityForName:[CFeed entityName] predicate:thePredicate createIfNotFound:YES wasCreated:&theWasCreatedFlag error:&theError];
if (theWasCreatedFlag == YES && inFetchFlag == YES)
	{
	theFeed.URL = inURL.absoluteString;
	[self.feedFetcher updateFeed:theFeed];
	}

return(theFeed);
}

@end
