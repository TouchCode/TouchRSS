//
//  CFeedEntriesViewController.m
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

#import "CFeedEntriesViewController.h"

#import "CFeedEntryViewController.h"
#import "CFeedStore.h"
#import "CFeedEntry.h"
#import "CFeed.h"
#import "NSURL_DataExtensions.h"
#import "TouchRSS_iPhoneAppDelegate.h"

@implementation CFeedEntriesViewController

@synthesize feedStore;
@synthesize feeds;

- (id)initWithFeedStore:(CFeedStore *)inFeedStore feed:(CFeed *)inFeed;
{
if ((self = [super init]) != NULL)
	{
	self.title = inFeed.title;
	//
	self.feedStore = inFeedStore;
	self.managedObjectContext = inFeedStore.managedObjectContext;

	self.feed = inFeed;
	}
return(self);
}

- (void)dealloc
{
//
[super dealloc];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
return(YES);
}

- (void)viewDidLoad
{
[super viewDidLoad];
//
UILabel *thePlaceholderLabel = (UILabel *)self.placeholderView;
thePlaceholderLabel.text = @"No entries";
}

#pragma mark -

- (CFeed *)feed
{
return([self.feeds lastObject]);
}

- (void)setFeed:(CFeed *)inFeed
{
[self setFeeds:[NSArray arrayWithObject:inFeed]];
}

- (void)setFeeds:(NSArray *)inFeeds
{
if (feeds != inFeeds)
	{
	if (feeds != NULL)
		{
		[feeds release];
		feeds = NULL;

		self.fetchedResultsController.delegate = NULL;
		self.fetchedResultsController = NULL;
		}

	if (inFeeds)
		{
		NSEntityDescription *theEntityDescription = [NSEntityDescription entityForName:[CFeedEntry entityName] inManagedObjectContext:self.managedObjectContext];
		NSAssert(theEntityDescription != NULL, @"No entity description.");
		NSFetchRequest *theFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		theFetchRequest.entity = theEntityDescription;
		theFetchRequest.predicate = [NSPredicate predicateWithFormat:@"feed IN %@", inFeeds];

		NSArray *theSortDescriptors = [NSArray arrayWithObjects:
			[[[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO] autorelease],
			NULL];
		theFetchRequest.sortDescriptors = theSortDescriptors;

		self.fetchRequest = theFetchRequest;
		}
	}
}

#pragma mark Table view methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
static NSString *theCellIdentifier = @"Cell";

UITableViewCell *theCell = [tableView dequeueReusableCellWithIdentifier:theCellIdentifier];
if (theCell == NULL)
	{
	theCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:theCellIdentifier] autorelease];
	theCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

CFeedEntry *theEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];

theCell.textLabel.text = theEntry.title;

return(theCell);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
CFeedEntry *theEntry = [self.fetchedResultsController objectAtIndexPath:indexPath];

CFeedEntryViewController *theFeedEntryView = [[[CFeedEntryViewController alloc] initWithFetchedResultsController:self.fetchedResultsController] autorelease];
theFeedEntryView.entry = theEntry;

if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
	[[[TouchRSS_iPhoneAppDelegate instance].splitViewController.viewControllers objectAtIndex:1] setViewControllers:[NSArray arrayWithObject:theFeedEntryView]];
	}
else
	{
	[self.navigationController pushViewController:theFeedEntryView animated:YES];
	}
}

@end

