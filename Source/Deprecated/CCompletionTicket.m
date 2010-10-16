//
//  CCompletionTicket.m
//  TouchCode
//
//  Created by Jonathan Wight on 8/22/08.
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

#import "CCompletionTicket.h"

#import "CPointerArray.h"

@interface CCompletionTicket ()
@property (readwrite, nonatomic, retain) NSString *identifier;
@property (readwrite, nonatomic, retain) CPointerArray *delegatePointers;
@property (readwrite, nonatomic, retain) id userInfo;
@property (readwrite, nonatomic, retain) CCompletionTicket *subTicket;
@end

@implementation CCompletionTicket

@synthesize identifier;
@dynamic delegates;
@synthesize delegatePointers;
@synthesize userInfo;
@synthesize subTicket;

+ (CCompletionTicket *)completionTicketWithIdentifier:(NSString *)inIdentifier delegate:(id <CCompletionTicketDelegate>)inDelegate userInfo:(id)inUserInfo
{
return([[[self alloc] initWithIdentifier:inIdentifier delegate:inDelegate userInfo:inUserInfo subTicket:NULL] autorelease]);
}

+ (CCompletionTicket *)completionTicketWithIdentifier:(NSString *)inIdentifier delegate:(id <CCompletionTicketDelegate>)inDelegate userInfo:(id)inUserInfo subTicket:(CCompletionTicket *)inSubTicket;
{
return([[[self alloc] initWithIdentifier:inIdentifier delegate:inDelegate userInfo:inUserInfo subTicket:inSubTicket] autorelease]);
}

- (id)initWithIdentifier:(NSString *)inIdentifier delegates:(NSArray *)inDelegates userInfo:(id)inUserInfo subTicket:(CCompletionTicket *)inSubTicket
{
if ((self = [super init]) != NULL)
	{
	self.identifier = inIdentifier;
	self.delegatePointers = [[[CPointerArray alloc] init] autorelease];
	for (id theDelegate in inDelegates)
		{
		NSAssert([theDelegate conformsToProtocol:@protocol(CCompletionTicketDelegate)], @"Delegate does not conform to CCompletionTicketDelegate protocol");
		[self.delegatePointers addPointer:theDelegate];
		}
	self.userInfo = inUserInfo;
	self.subTicket = inSubTicket;
	}
return(self);
}

- (id)initWithIdentifier:(NSString *)inIdentifier delegate:(id <CCompletionTicketDelegate>)inDelegate userInfo:(id)inUserInfo subTicket:(CCompletionTicket *)inSubTicket
{
if ((self = [self initWithIdentifier:inIdentifier delegates:[NSArray arrayWithObject:inDelegate] userInfo:inUserInfo subTicket:inSubTicket]) != NULL)
	{
	
	}
return(self);
}

- (void)dealloc
{
self.identifier = NULL;
self.delegatePointers = NULL;
self.userInfo = NULL;
self.subTicket = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSArray *)delegates
{
NSMutableArray *theArray = [NSMutableArray arrayWithCapacity:self.delegatePointers.count];
for (id <CCompletionTicketDelegate> theDelegate in self.delegatePointers)
	{
	[theArray addObject:theDelegate];
	}
return(theArray);
}

#pragma mark -

- (void)addDelegate:(id <CCompletionTicketDelegate>)inDelegate;
{
[self.delegatePointers addPointer:inDelegate];
}

- (void)invalidate
{
self.delegatePointers = NULL;
}

- (void)didBeginForTarget:(id)inTarget
{
for (id <CCompletionTicketDelegate> theDelegate in self.delegatePointers)
	{
	if ([theDelegate respondsToSelector:@selector(completionTicket:didBeginForTarget:)])
		[theDelegate completionTicket:self didBeginForTarget:inTarget];
	}
}

- (void)didCompleteForTarget:(id)inTarget result:(id)inResult
{
for (id <CCompletionTicketDelegate> theDelegate in self.delegatePointers)
	{
	if ([theDelegate respondsToSelector:@selector(completionTicket:didCompleteForTarget:result:)])
		[theDelegate completionTicket:self didCompleteForTarget:inTarget result:inResult];
	}
}

- (void)didFailForTarget:(id)inTarget error:(NSError *)inError
{
for (id <CCompletionTicketDelegate> theDelegate in self.delegatePointers)
	{
	if ([theDelegate respondsToSelector:@selector(completionTicket:didFailForTarget:error:)])
		[theDelegate completionTicket:self didFailForTarget:inTarget error:inError];
	}
}

- (void)didCancelForTarget:(id)inTarget
{
for (id <CCompletionTicketDelegate> theDelegate in self.delegatePointers)
	{
	if ([theDelegate respondsToSelector:@selector(completionTicket:didCancelForTarget:)])
		[theDelegate completionTicket:self didCancelForTarget:inTarget];
	}
}

@end
