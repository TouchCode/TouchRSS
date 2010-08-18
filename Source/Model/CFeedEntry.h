//
//  CFeedEntry.h
//  TouchCode
//
//  Created by Jonathan Wight on 20091204.
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

//
//  CFeedEntry.h
//  <#ProjectName#>
//
//  Created by Jonathan Wight on 09/20/09
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CObjectTranscoder;

#pragma mark begin emogenerator forward declarations
@class CFeed;
#pragma mark end emogenerator forward declarations

/** Entry */
@interface CFeedEntry : NSManagedObject {
}

+ (NSArray *)persistentPropertyNames;
+ (CObjectTranscoder *)objectTranscoder;

#pragma mark begin emogenerator accessors

+ (NSString *)entityName;

// Attributes
@property (readwrite, retain) NSDate *updated;
@property (readwrite, retain) NSString *thumbnailURL;
@property (readwrite, retain) NSString *content;
@property (readwrite, retain) NSString *subtitle;
@property (readwrite, retain) id extraXML;
@property (readwrite, retain) NSString *title;
@property (readwrite, retain) NSString *identifier;
@property (readwrite, retain) NSString *link;

// Relationships
@property (readwrite, retain) CFeed *feed;
- (CFeed *)feed;
- (void)setFeed:(CFeed *)inFeed;

#pragma mark end emogenerator accessors

@end
