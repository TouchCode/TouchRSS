//
//  CCompletionTicket.h
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

#import <Foundation/Foundation.h>

@protocol CCompletionTicketDelegate;
@class CPointerArray;

@interface CCompletionTicket : NSObject {
	NSString *identifier;
	CPointerArray *delegatePointers;
	id userInfo;
	CCompletionTicket *subTicket;
}

@property (readonly, nonatomic, retain) NSString *identifier;
@property (readonly, nonatomic, retain) NSArray *delegates;
@property (readonly, nonatomic, retain) id userInfo;
@property (readonly, nonatomic, retain) CCompletionTicket *subTicket;

+ (CCompletionTicket *)completionTicketWithIdentifier:(NSString *)inIdentifier delegate:(id <CCompletionTicketDelegate>)inDelegate userInfo:(id)inUserInfo;
+ (CCompletionTicket *)completionTicketWithIdentifier:(NSString *)inIdentifier delegate:(id <CCompletionTicketDelegate>)inDelegate userInfo:(id)inUserInfo subTicket:(CCompletionTicket *)inSubTicket;

- (id)initWithIdentifier:(NSString *)inIdentifier delegates:(NSArray *)inDelegates userInfo:(id)inUserInfo subTicket:(CCompletionTicket *)inSubTicket;
- (id)initWithIdentifier:(NSString *)inIdentifier delegate:(id <CCompletionTicketDelegate>)inDelegate userInfo:(id)inUserInfo subTicket:(CCompletionTicket *)inSubTicket;

- (void)addDelegate:(id <CCompletionTicketDelegate>)inDelegate;

- (void)invalidate;

- (void)didBeginForTarget:(id)inTarget;
- (void)didCompleteForTarget:(id)inTarget result:(id)inResult;
- (void)didFailForTarget:(id)inTarget error:(NSError *)inError;
- (void)didCancelForTarget:(id)inTarget;

@end

#pragma mark -

@protocol CCompletionTicketDelegate <NSObject>

@required
- (void)completionTicket:(CCompletionTicket *)inCompletionTicket didCompleteForTarget:(id)inTarget result:(id)inResult;

@optional
- (void)completionTicket:(CCompletionTicket *)inCompletionTicket didBeginForTarget:(id)inTarget;
- (void)completionTicket:(CCompletionTicket *)inCompletionTicket didFailForTarget:(id)inTarget error:(NSError *)inError;
- (void)completionTicket:(CCompletionTicket *)inCompletionTicket didCancelForTarget:(id)inTarget;

@end
