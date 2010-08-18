//
//  CFeedEntryViewController.m
//  TouchCode
//
//  Created by Jonathan Wight on 04/06/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
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

#import "CFeedEntryViewController.h"

#import "CFeedEntry.h"
#import "NSURL_DataExtensions.h"
#import "CTrivialTemplate.h"
#import "CURLOpener.h"

@implementation CFeedEntryViewController

@synthesize fetchedResultsController;
@synthesize entry;
@synthesize contentTemplate;
@synthesize nextPreviousSegmentedControl;
@synthesize nextPreviousBarButtonItem;

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)inFetchedResultsController
{
if ((self = [super init]) != NULL)
	{
	fetchedResultsController = [inFetchedResultsController retain];

	NSError *theError = NULL;
	[fetchedResultsController performFetch:&theError];
	}
return(self);
}

- (void)dealloc
{

[super dealloc];
}

#pragma mark -

- (void)viewDidLoad
{
[super viewDidLoad];

self.navigationItem.rightBarButtonItem = self.nextPreviousBarButtonItem;
}

#pragma mark -

- (void)updateUI;
{
[super updateUI];
//
NSInteger theCurrentEntryIndex = self.currentEntryIndex;

[self.nextPreviousSegmentedControl setEnabled:theCurrentEntryIndex > 0 forSegmentAtIndex:0];
[self.nextPreviousSegmentedControl setEnabled:theCurrentEntryIndex < self.countOfEntries - 1 forSegmentAtIndex:1];

//if (self.isHome)
//	[self hideToolbar];
//else
//	[self showToolbar];
}

#pragma mark -

- (NSInteger)currentEntryIndex
{
return([self.fetchedResultsController.fetchedObjects indexOfObject:self.entry]);
}

- (void)setCurrentEntryIndex:(NSInteger)inCurrentRow
{
if (inCurrentRow < 0)
	return;
else if (inCurrentRow > [self.fetchedResultsController.fetchedObjects count] - 1)
	return;

CFeedEntry *theEntry = [self.fetchedResultsController.fetchedObjects objectAtIndex:inCurrentRow];
self.entry = theEntry;
}

- (NSInteger)countOfEntries
{
return([self.fetchedResultsController.fetchedObjects count]);
}

- (void)setEntry:(CFeedEntry *)inEntry
{
if (entry != inEntry)
	{
	if (entry != NULL)
		{
		[entry release];
		entry = NULL;
		}

	if (inEntry)
		{
		entry = [inEntry retain];

		NSDictionary *theReplacementDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
			inEntry, @"entry",
			self, @"controller",
			NULL];
		NSError *theError = NULL;
		NSString *theContent = [self.contentTemplate transform:theReplacementDictionary error:&theError];
		NSData *theData = [theContent dataUsingEncoding:NSUTF8StringEncoding];
		NSURL *theURL = [NSURL dataURLWithData:theData mimeType:@"text/html" charset:@"utf-8"];

		[self resetWebView];

		self.homeURL = theURL;
		self.requestedURL = theURL;
		}
	}
}

- (CTrivialTemplate *)contentTemplate
{
if (contentTemplate == NULL)
	{
	contentTemplate = [[CTrivialTemplate alloc] initWithTemplateName:@"Entry_Template.html"];
	}
return(contentTemplate);
}

- (UISegmentedControl *)nextPreviousSegmentedControl
{
if (nextPreviousSegmentedControl == NULL)
	{
	NSArray *theItems = [NSArray arrayWithObjects:
		[UIImage imageNamed:@"browser-previous.png"],
		[UIImage imageNamed:@"browser-next.png"],
		NULL
		];

	nextPreviousSegmentedControl = [[UISegmentedControl alloc] initWithItems:theItems];
	nextPreviousSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	nextPreviousSegmentedControl.momentary = YES;
	[nextPreviousSegmentedControl addTarget:self action:@selector(actionPreviousNext:) forControlEvents:UIControlEventValueChanged];
	}
return(nextPreviousSegmentedControl);
}

- (UIBarButtonItem *)nextPreviousBarButtonItem
{
if (nextPreviousBarButtonItem == NULL)
	{
	nextPreviousBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextPreviousSegmentedControl];
	}
return(nextPreviousBarButtonItem);
}

#pragma mark -

- (IBAction)next:(id)inSender
{
self.currentEntryIndex += 1;
}

- (IBAction)previous:(id)inSender
{
self.currentEntryIndex -= 1;
}

- (IBAction)actionPreviousNext:(id)inSender
{
switch ([(UISegmentedControl *)inSender selectedSegmentIndex])
	{
	case 0:
		[self previous:inSender];
		break;
	case 1:
		[self next:inSender];
		break;
	}
}

- (IBAction)action:(id)inSender
{
NSURL *theURL = self.currentURL;
if (self.isHome)
	theURL = [NSURL URLWithString:self.entry.link];


CURLOpener *theActionSheet = [[[CURLOpener alloc] initWithParentViewController:self URL:theURL] autorelease];
if ([theActionSheet respondsToSelector:@selector(showFromBarButtonItem:animated:)])
	[theActionSheet showFromBarButtonItem:inSender animated:YES];
else
	[theActionSheet showFromToolbar:self.toolbar];
}


@end
