//
//  CURLConnectionManagerChannel.h
//  TouchCode
//
//  Created by Jonathan Wight on 06/18/08.
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

@class CURLConnectionManager;

/** CURLConnectionManagerChannel is used by CURLConnectionManager to represent a "channel" of active and waiting connections. Generally you do not create these objects yourself, but rely on CURLConnection manager to create them for you. */
@interface CURLConnectionManagerChannel : NSObject {
	CURLConnectionManager *manager;
	NSString *name;
	NSMutableSet *activeConnections;
	NSMutableArray *waitingConnections;
	NSUInteger maximumConnections;
}

@property (readonly, nonatomic, assign) CURLConnectionManager *manager;
@property (readonly, nonatomic, retain) NSString *name;
@property (readonly, nonatomic, retain) NSMutableSet *activeConnections;
@property (readonly, nonatomic, retain) NSMutableArray *waitingConnections;
@property (readwrite, nonatomic, assign) NSUInteger maximumConnections;

- (id)initWithManager:(CURLConnectionManager *)inManager name:(NSString *)inName;

- (void)cancelAll:(BOOL)inCancelActiveConnections;

@end
