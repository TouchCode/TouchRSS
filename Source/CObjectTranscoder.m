//
//  CObjectTranscoder.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/11/08.
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

#import "CObjectTranscoder.h"

//#import "NSDate_SqlExtension.h"
//#import "NSDictionary_SqlExtensions.h"

#import <objc/runtime.h>

static const char* getPropertyType(objc_property_t property);

@implementation CObjectTranscoder

@synthesize targetObjectClass;
@synthesize propertyNameMappings;

- (id)initWithTargetObjectClass:(Class)inTargetObjectClass
{
if ((self = [super init]) != NULL)
	{
	self.targetObjectClass = inTargetObjectClass;
	}
return(self);
}

- (void)dealloc
{
self.propertyNameMappings = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSDictionary *)invertedPropertyNameMappings
{
if (invertedPropertyNameMappings == NULL)
	{
	NSMutableDictionary *theDictionary = [NSMutableDictionary dictionaryWithCapacity:self.propertyNameMappings.count];
	for (id theKey in self.propertyNameMappings)
		{
		[theDictionary setObject:theKey forKey:[self.propertyNameMappings objectForKey:theKey]];
		}
	invertedPropertyNameMappings = [theDictionary copy];
	}
return(invertedPropertyNameMappings);
}

- (NSDictionary *)dictionaryForObjectUpdate:(id)inObject withPropertiesInDictionary:(NSDictionary *)inDictionary error:(NSError **)outError
{
NSAssert([inObject isKindOfClass:self.targetObjectClass], @"");

NSMutableDictionary *theMappedValuesAndKeys = [NSMutableDictionary dictionaryWithCapacity:[inDictionary count]];

Class theClass = [inObject class];
for (NSString *theKey in inDictionary)
	{
	// Grab the value early before we change the key name.
	id theValue = [inDictionary objectForKey:theKey];

	if ([self.propertyNameMappings objectForKey:theKey])
		{
		theKey = [self.propertyNameMappings objectForKey:theKey];
		}

	objc_property_t theProperty = class_getProperty(theClass, [theKey UTF8String]);
	if (theProperty == NULL)
		{
//		NSLog(@"WARNING: NO SUCH PROPERTY: %@", theKey);
		continue;
		}

	const char *thePropertyAttributes = property_getAttributes(theProperty);
	BOOL theIsObjectFlag = NO;
	if (strncmp(thePropertyAttributes, "T@", 2) == 0)
		theIsObjectFlag = YES;
	const char *thePropertyType = getPropertyType(theProperty);
	if (theIsObjectFlag == NO)
		{
		switch (thePropertyType[0])
			{
			case 'c':
			case 'i':
				{
				if (theValue == [NSNull null])
					{
					continue;
					}
				else if ([theValue respondsToSelector:@selector(intValue)] == NO)
					{
					if (outError)
						{
						NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"Object of class %@ does not respond to intValue", NSStringFromClass([theValue class])], NSLocalizedDescriptionKey,
							NULL
							];
						*outError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-1 userInfo:theUserInfo];
						}
					return(NULL);
					}
				[inObject setValue:theValue forKey:theKey];
				}
				break;
			case 'd':
				{
				if (theValue == [NSNull null])
					{
					continue;
					}
				else if ([theValue respondsToSelector:@selector(doubleValue)] == NO)
					{
					if (outError)
						{
						NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"Object of class %@ does not respond to doubleValue", NSStringFromClass([theValue class])], NSLocalizedDescriptionKey,
							NULL
							];
						*outError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-2 userInfo:theUserInfo];
						}
					return(NULL);
					}
				[inObject setValue:theValue forKey:theKey];
				}
				break;
			default:
				NSLog(@"#### NOT HANDLING TYPE: %s", thePropertyType);
				NSAssert(NO, @"");
				break;
			}
		}
	else
		{
		if (strcmp(thePropertyType, "@") == 0)
			{
			// Nothing to do here.
			}
		else
			{
			char theBuffer[strlen(thePropertyType) + 1];
			strncpy(theBuffer, thePropertyType + 2, strlen(thePropertyType) - 3);
			theBuffer[strlen(thePropertyType) - 3] = '\0';
			theValue = [self transformObject:theValue toObjectOfClass:NSClassFromString([NSString stringWithUTF8String:theBuffer]) error:outError];
			}

		}

	if (theValue)
		[theMappedValuesAndKeys setObject:theValue forKey:theKey];
	}
return(theMappedValuesAndKeys);
}

- (BOOL)updateObject:(id)inObject withPropertiesInDictionary:(NSDictionary *)inDictionary error:(NSError **)outError;
{
for (NSString *theKey in inDictionary)
	{
	id theValue = [inDictionary objectForKey:theKey];
	[inObject setValue:theValue forKey:theKey];
	}

return(YES);
}

#pragma mark -

- (id)transformObject:(id)inObject toObjectOfClass:(Class)inTargetClass error:(NSError **)outError
{
if ([inObject isKindOfClass:[NSString class]] && inTargetClass == [NSString class])
	{
	return(inObject);
	}
else if ([inObject isKindOfClass:[NSString class]] && inTargetClass == [NSURL class])
	{
	return([NSURL URLWithString:inObject]);
	}
else if ([inObject isKindOfClass:[NSDate class]] && inTargetClass == [NSDate class])
	{
	return(inObject);
	}
else if ([inObject isKindOfClass:[NSURL class]] && inTargetClass == [NSURL class])
	{
	return(inObject);
	}
else if ([inObject isKindOfClass:[NSURL class]] && inTargetClass == [NSString class])
	{
	return([inObject description]);
	}
else if ([inObject isKindOfClass:[NSDictionary class]] && inTargetClass == [NSDictionary class])
	{
	return(inObject);
	}
else if ([inObject isKindOfClass:[NSNumber class]] && inTargetClass == [NSString class])
	{
	return([inObject stringValue]);
	}
else if ([inObject isKindOfClass:[NSNull class]])
	{
	return(NULL);
	}
else
	{
//	NSLog(@"WARNING: cannot convert object of class %@ to %@", NSStringFromClass([inObject class]), NSStringFromClass(inTargetClass));
	}

if (outError)
	{
	NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSString stringWithFormat:@"cannot convert object of class %@ to %@", NSStringFromClass([inObject class]), NSStringFromClass(inTargetClass)], NSLocalizedDescriptionKey,
		NULL
		];
	*outError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-1 userInfo:theUserInfo];
	}
return(NULL);
}

#pragma mark -

@end

static const char* getPropertyType(objc_property_t property) {
    // parse the property attribues. this is a comma delimited string. the type of the attribute starts with the
    // character 'T' should really just use strsep for this, using a C99 variable sized array.
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            // return a pointer scoped to the autorelease pool. Under GC, this will be a separate block.
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute)] bytes];
        }
    }
    return "@";
}
