//
//  CFeedFetcher.h
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

#import <Foundation/Foundation.h>

#import "CCompletionTicket.h"

@class CFeedStore;
@class CRSSFeedDeserializer;
@class CFeed;

@protocol CFeedFetcherDelegate;

@interface CFeedFetcher : NSObject <CCompletionTicketDelegate> {
	CFeedStore *feedStore; // Never retained.
	id <CFeedFetcherDelegate> delegate;
	NSTimeInterval fetchInterval;
	//
	NSTimer *fetchTimer;
	NSMutableSet *currentURLs;
}

@property (readonly, nonatomic, assign) CFeedStore *feedStore;
@property (readwrite, nonatomic, assign) id <CFeedFetcherDelegate> delegate;
@property (readwrite, nonatomic, assign) NSTimeInterval fetchInterval;

- (id)initWithFeedStore:(CFeedStore *)inFeedStore;

- (CRSSFeedDeserializer *)deserializerForData:(NSData *)inData;
- (CFeed *)subscribeToURL:(NSURL *)inURL error:(NSError **)outError;
- (BOOL)updateFeed:(CFeed *)inFeed;
- (BOOL)updateFeed:(CFeed *)inFeed completionTicket:(CCompletionTicket *)inCompletionTicket;
- (void)cancel;

@end

#pragma mark -

@protocol CFeedFetcherDelegate <NSObject>

@optional
- (BOOL)feedFetcher:(CFeedFetcher *)inFeedFetcher shouldFetchFeed:(CFeed *)inFeed;
- (void)feedFetcher:(CFeedFetcher *)inFeedFetcher didFetchFeed:(CFeed *)inFeed;
- (void)feedFetcher:(CFeedFetcher *)inFeedFetcher didFailFetchingFeed:(CFeed *)inFeed withError:(NSError *)inError;

@end
