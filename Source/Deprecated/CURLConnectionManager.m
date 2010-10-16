//
//  CURLConnectionManager.m
//  TouchCode
//
//  Created by Jonathan Wight on 04/23/08.
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

#import "CURLConnectionManager.h"

#import "CURLConnectionManagerChannel.h"

// TODO put into a header?
@interface CManagedURLConnection (CManagedURLConnection_PrivateExtensions)
@property (readwrite, nonatomic, assign) CURLConnectionManager *manager;
@end

#pragma mark -

static CURLConnectionManager *gInstance = NULL;

@interface CURLConnectionManager ()

@property (readwrite, nonatomic, assign) BOOL started;
@property (readwrite, nonatomic, retain) NSMutableDictionary *channels;
@property (readwrite, nonatomic, assign) NSInteger activeConnectionCount;

@end

#pragma mark -

@implementation CURLConnectionManager

@synthesize started;
@synthesize channels;
@synthesize activeConnectionCount;

+ (CURLConnectionManager *)instance;
{
@synchronized(self)
	{
	if (gInstance == NULL)
		{
		gInstance = [[self alloc] init];
		}
	}	
return(gInstance);
}

- (id)init
{
if ((self = [super init]) != nil)
	{
	self.started = NO;
	self.channels = [NSMutableDictionary dictionary];
	//
	[self start];
	}
return(self);
}

- (void)dealloc
{
[self stop];

// TODO cancel all activeConnections?
self.channels = NULL;

[super dealloc];
}

- (void)start
{
self.started = YES;
[self processConnections];
}

- (void)stop
{
self.started = NO;
}

#pragma mark -

- (void)addAutomaticURLConnection:(CManagedURLConnection *)inConnection toChannel:(NSString *)inChannel
{
[inConnection.completionTicket addDelegate:self];

CURLConnectionManagerChannel *theChannel = [self.channels objectForKey:inChannel];
if (theChannel == NULL)
	{
	theChannel = [[[CURLConnectionManagerChannel alloc] initWithManager:self name:inChannel] autorelease];
	[self.channels setObject:theChannel forKey:inChannel];
	}
inConnection.channel = inChannel;
[theChannel.waitingConnections insertObject:inConnection atIndex:0];
//
[self processConnections];
}

- (void)processConnections
{
if (self.started == YES)
	{
	NSInteger theTotalActiveConnections = 0;
	
	for (CURLConnectionManagerChannel *theChannel in self.channels.allValues)
		{
		NSUInteger theSpareConnections = MIN(theChannel.maximumConnections - theChannel.activeConnections.count, theChannel.waitingConnections.count);
		if (theSpareConnections > 0)
			{
			for (; theSpareConnections != 0; --theSpareConnections)
				{
				CManagedURLConnection *theConnection = [theChannel.waitingConnections objectAtIndex:0];
				[theChannel.activeConnections addObject:theConnection];
				[theChannel.waitingConnections removeObjectAtIndex:0];
				
				[theConnection start];
				}
			}

		theTotalActiveConnections += theChannel.activeConnections.count;
		}

	self.activeConnectionCount = theTotalActiveConnections;
	}
}

- (CURLConnectionManagerChannel *)channelForName:(NSString *)inName;
{
return([self.channels objectForKey:inName]);
}

#pragma mark -

- (void)completionTicket:(CCompletionTicket *)inCompletionTicket didCompleteForTarget:(id)inTarget result:(id)inResult
{
NSAssert([inTarget isKindOfClass:[CManagedURLConnection class]], @"Target is not CManagedURLConnection");
CManagedURLConnection *theConnection = (CManagedURLConnection *)inTarget;
CURLConnectionManagerChannel *theChannel = [self.channels objectForKey:theConnection.channel];
[theChannel.activeConnections removeObject:theConnection];
[theChannel.waitingConnections removeObject:theConnection];
//
[self processConnections];
}

- (void)completionTicket:(CCompletionTicket *)inCompletionTicket didFailForTarget:(id)inTarget error:(NSError *)inError
{
NSAssert([inTarget isKindOfClass:[CManagedURLConnection class]], @"Target is not CManagedURLConnection");
CManagedURLConnection *theConnection = (CManagedURLConnection *)inTarget;
CURLConnectionManagerChannel *theChannel = [self.channels objectForKey:theConnection.channel];
[theChannel.activeConnections removeObject:theConnection];
[theChannel.waitingConnections removeObject:theConnection];
//
[self processConnections];
}

- (void)completionTicket:(CCompletionTicket *)inCompletionTicket didCancelForTarget:(id)inTarget
{
NSAssert([inTarget isKindOfClass:[CManagedURLConnection class]], @"Target is not CManagedURLConnection");
CManagedURLConnection *theConnection = (CManagedURLConnection *)inTarget;
CURLConnectionManagerChannel *theChannel = [self.channels objectForKey:theConnection.channel];
[theChannel.activeConnections removeObject:theConnection];
[theChannel.waitingConnections removeObject:theConnection];
//
[self processConnections];
}

@end

#pragma mark -

//@implementation CURLConnectionManager (CURLConnectionManager_ConvenienceMethods)
//
//- (void)addAutomaticURLConnectionForRequest:(NSURLRequest *)inRequest toChannel:(NSString *)inChannel delegate:(id)inDelegate
//{
//CManagedURLConnection *theConnection = [[[CManagedURLConnection alloc] initWithRequest:inRequest identifier:NULL delegate:inDelegate userInfo:NULL] autorelease];
//[self addAutomaticURLConnection:theConnection toChannel:inChannel];
//}
//
//@end
