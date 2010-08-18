//
//  CFeedEntry.m
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
//  CFeedEntry.m
//  <#ProjectName#>
//
//  Created by Jonathan Wight on 09/20/09
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//

#import "CFeedEntry.h"

#import "CObjectTranscoder.h"

#pragma mark begin emogenerator forward declarations
#import "CFeed.h"
#pragma mark end emogenerator forward declarations

@implementation CFeedEntry

+ (NSArray *)persistentPropertyNames
{
return([NSArray arrayWithObjects:@"feed", @"identifier", @"title", @"subtitle", @"content", @"link", @"updated", NULL]);
}

+ (CObjectTranscoder *)objectTranscoder
{
CObjectTranscoder *theTranscoder = [[[CObjectTranscoder alloc] initWithTargetObjectClass:[self class]] autorelease];
theTranscoder.propertyNameMappings = [NSDictionary dictionaryWithObjectsAndKeys:
//	@"rowID", @"id",
//	@"feed", @"feed_id",
	NULL];
return(theTranscoder);
}


#pragma mark begin emogenerator accessors

+ (NSString *)entityName
{
return(@"Entry");
}

@dynamic updated;

@dynamic thumbnailURL;

@dynamic content;

@dynamic subtitle;

@dynamic extraXML;

@dynamic title;

@dynamic feed;

- (CFeed *)feed
{
[self willAccessValueForKey:@"feed"];
CFeed *theResult = [self primitiveValueForKey:@"feed"];
[self didAccessValueForKey:@"feed"];
return(theResult);
}

- (void)setFeed:(CFeed *)inFeed
{
[self willChangeValueForKey:@"feed"];
[self setPrimitiveValue:inFeed forKey:@"feed"];
[self didChangeValueForKey:@"feed"];
}

@dynamic identifier;

@dynamic link;

#pragma mark end emogenerator accessors

@end
