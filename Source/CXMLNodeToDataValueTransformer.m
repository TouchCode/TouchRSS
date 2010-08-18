//
//  CXMLNodeToDataValueTransformer.m
//  TouchCode
//
//  Created by Jonathan Wight on 04/22/10.
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

#import "CXMLNodeToDataValueTransformer.h"

#import "CXMLDocument.h"
#import "CXMLElement.h"

@implementation CXMLNodeToDataValueTransformer

+ (void)load
{
NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];
//
[self setValueTransformer:[[[self alloc] init] autorelease] forName:NSStringFromClass(self)];
//
[thePool release];
}

+ (Class)transformedValueClass
{
return([NSData class]);
}

+ (BOOL)allowsReverseTransformation
{
return(YES);
}

- (id)transformedValue:(id)value
{
NSData *theData = NULL;

if ([value isKindOfClass:[NSDictionary class]])
	{
	NSMutableDictionary *theStrings = [NSMutableDictionary dictionary];
	
	for (NSString *theKey in value)
		{
		CXMLElement *theElement = [value objectForKey:theKey];
		[theStrings setObject:[theElement XMLString] forKey:theKey];
		}

	theData = [NSKeyedArchiver archivedDataWithRootObject:theStrings];
	}
return(theData);
}

- (id)reverseTransformedValue:(id)value
{
NSDictionary *theStringsDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:value];
NSMutableDictionary *theElementsDictionary = [NSMutableDictionary dictionary];
for (NSString *theKey in theStringsDictionary)
	{
	NSString *theString = [theStringsDictionary objectForKey:theKey];

	NSError *theError = NULL;
	CXMLDocument *theDocument = [[[CXMLDocument alloc] initWithXMLString:theString options:0 error:&theError] autorelease];
	if (theDocument == NULL)
		{
		NSLog(@"Warning: couldn't process XML: %@", theError);
		}
	else
		{
		CXMLElement *theRootElement = [[[theDocument rootElement] copy] autorelease];
		[theElementsDictionary setObject:theRootElement forKey:theKey];
		}
	}

return(theElementsDictionary);
}

@end
