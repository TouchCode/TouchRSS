//
//  CURLConnectionManagerChannel.m
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

#import "CURLConnectionManagerChannel.h"

#import "CURLConnectionManager.h"

@interface CURLConnectionManagerChannel ()
@property (readwrite, nonatomic, assign) CURLConnectionManager *manager;
@property (readwrite, nonatomic, retain) NSString *name;
@property (readwrite, nonatomic, retain) NSMutableSet *activeConnections;
@property (readwrite, nonatomic, retain) NSMutableArray *waitingConnections;
@end

#pragma mark -

@implementation CURLConnectionManagerChannel

@synthesize manager;
@synthesize name;
@synthesize activeConnections;
@synthesize waitingConnections;
@dynamic maximumConnections;

- (id)initWithManager:(CURLConnectionManager *)inManager name:(NSString *)inName
{
if ((self = [super init]) != NULL)
	{
	self.manager = inManager;
	self.name = inName;
	self.activeConnections = [NSMutableSet set];
	self.waitingConnections = [NSMutableArray array];
	self.maximumConnections = 4;
	}
return(self);
}

- (void)dealloc
{
self.manager = NULL;
self.name = NULL;
self.activeConnections = NULL;
self.waitingConnections = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSUInteger)maximumConnections
{
return(maximumConnections);
}

- (void)setMaximumConnections:(NSUInteger)inMaximumConnections
{
if (maximumConnections != inMaximumConnections)
	{
	maximumConnections = inMaximumConnections;
	//
	[self.manager processConnections];
	}
}

- (void)cancelAll:(BOOL)inCancelActiveConnections
{
// Cancel all waiting connections.
for (CManagedURLConnection *theConnection in [[self.waitingConnections copy] autorelease])
	{
	[theConnection cancel];
	[self.waitingConnections removeObject:theConnection];
	}

if (inCancelActiveConnections)
	{
	for (CManagedURLConnection *theConnection in [[self.activeConnections copy] autorelease])
		{
		[theConnection cancel];
		[self.waitingConnections removeObject:theConnection];
		}
	}
}

@end
