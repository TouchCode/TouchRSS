//
//  TouchRSS_iPhoneAppDelegate.m
//  TouchCode
//
//  Created by Jonathan Wight on 10/4/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
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

#import "TouchRSS_iPhoneAppDelegate.h"
#import "CFeedsViewController.h"

@implementation TouchRSS_iPhoneAppDelegate

@synthesize window;
@synthesize rootViewController;
@synthesize splitViewController;

static TouchRSS_iPhoneAppDelegate *gInstance = NULL;

+ (TouchRSS_iPhoneAppDelegate *)instance;
{
return(gInstance);
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	gInstance = self;
	}
return(self);
}

- (void)dealloc
{
if (gInstance == self)
	gInstance = NULL;

[rootViewController release];
rootViewController = NULL;
//
[window release];
window = NULL;
//
[super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{       
[self.window addSubview:self.rootViewController.view];
[self.window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark -

#if defined(__IPHONE_3_2) && __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED

// Called when a button should be added to a toolbar for a hidden view controller
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{

//[[[TouchRSS_iPhoneAppDelegate instance].splitViewController.viewControllers objectAtIndex:1] 

barButtonItem.title = @"Feeds";
[[[[svc.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] navigationItem].leftBarButtonItem = barButtonItem;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
NSLog(@"B");
}

// Called when the view controller is shown in a popover so the delegate can take action like hiding other popovers.
- (void)splitViewController: (UISplitViewController*)svc popoverController: (UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController
{
NSLog(@"C");
}

#endif

@end

