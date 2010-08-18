//
//  CFeedEntryViewController.h
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

#import "CWebViewController.h"

#import <CoreData/CoreData.h>

@class CFeedEntry;
@class CTrivialTemplate;

@interface CFeedEntryViewController : CWebViewController {
	NSFetchedResultsController *fetchedResultsController;
	CFeedEntry *entry;
	CTrivialTemplate *contentTemplate;
	UISegmentedControl *nextPreviousSegmentedControl;
	UIBarButtonItem *nextPreviousBarButtonItem;
}

@property (readwrite, nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (readwrite, nonatomic, assign) NSInteger currentEntryIndex;
@property (readonly, nonatomic, assign) NSInteger countOfEntries;
@property (readwrite, nonatomic, retain) CFeedEntry *entry;
@property (readwrite, nonatomic, retain) CTrivialTemplate *contentTemplate;
@property (readonly, nonatomic, retain) UISegmentedControl *nextPreviousSegmentedControl;
@property (readonly, nonatomic, retain) UIBarButtonItem *nextPreviousBarButtonItem;

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)inFetchedResultsController;

- (IBAction)next:(id)inSender;
- (IBAction)previous:(id)inSender;

@end
