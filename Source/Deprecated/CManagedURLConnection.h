//
//  CManagedURLConnection.h
//  TouchCode
//
//  Created by Jonathan Wight on 04/16/08.
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

@class CCompletionTicket;

/** A URL Connection that does most of the grunt work for you. You should generally use this with CURLConnectionManager. */
@interface CManagedURLConnection : NSObject {
	CCompletionTicket *completionTicket;

	NSURLRequest *request;
	NSInteger priority;
	NSString *channel;
	NSURLConnection *connection;
	NSURLResponse *response;
	id privateData;
	BOOL dataIsMutable;
	NSURLCredential *credential;
	
	NSTimeInterval startTime;
	NSTimeInterval endTime;
}

@property (readwrite, nonatomic, retain) CCompletionTicket *completionTicket;

@property (readonly, nonatomic, retain) NSURLRequest *request;
@property (readwrite, nonatomic, assign) NSInteger priority;
@property (readwrite, nonatomic, retain) NSString *channel;

@property (readonly, nonatomic, retain) NSURLConnection *connection;
@property (readonly, nonatomic, retain) NSURLResponse *response;
@property (retain, nonatomic) NSURLCredential *credential;
 
@property (readonly, nonatomic, retain) NSData *data;

@property (readonly, nonatomic, assign) NSTimeInterval startTime;
@property (readonly, nonatomic, assign) NSTimeInterval endTime;

- (id)initWithRequest:(NSURLRequest *)inRequest completionTicket:(CCompletionTicket *)inCompletionTicket;

- (void)start;
- (void)cancel;

@end
