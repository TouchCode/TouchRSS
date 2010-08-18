//
//  CAtomFeedDeserializer.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/13/08.
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

#import "CAtomFeedDeserializer.h"

#import "AtomKeywords.h"

static void MyXMLTextReaderErrorFunc(void *arg, const char *msg, xmlParserSeverities severity, xmlTextReaderLocatorPtr locator);

@interface CAtomFeedDeserializer ()

@property (readwrite, nonatomic, assign) xmlTextReaderPtr reader;
@property (readwrite, nonatomic, retain) NSError *error;

- (NSDictionary *)dictionaryForAtomElement;

@end

#pragma mark -

@implementation CAtomFeedDeserializer

@synthesize reader;
@synthesize error;

- (id)initWithData:(NSData *)inData;
{
if ((self = [self init]) != NULL)
	{
	self.reader = xmlReaderForMemory([inData bytes], [inData length], NULL, NULL, 0);
	NSAssert(self.reader != NULL, @"");

	int theReturnCode = 0;

	xmlTextReaderSetErrorHandler(self.reader, MyXMLTextReaderErrorFunc, self);

//	theReturnCode = xmlTextReaderSetParserProp(self.reader, XML_PARSER_VALIDATE, 1);
//	NSAssert(theReturnCode == 0, @"");

	theReturnCode = xmlTextReaderSetParserProp(self.reader, XML_PARSER_SUBST_ENTITIES, 1);
	NSAssert(theReturnCode == 0, @"");
	}
return(self);
}

- (void)dealloc
{
xmlFreeTextReader(self.reader);
self.reader = NULL;

self.error = NULL;
//	
[super dealloc];
}

#pragma mark -

/*
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
 
 <title>Example Feed</title>
 <subtitle>A subtitle.</subtitle>
 <link href="http://example.org/feed/" rel="self"/>
 <link href="http://example.org/"/>
 <updated>2003-12-13T18:30:02Z</updated>
 <author>
   <name>John Doe</name>
   <email>johndoe@example.com</email>
 </author>
 <id>urn:uuid:60a76c80-d399-11d9-b91C-0003939e0af6</id>
 
 <entry>
   <title>Atom-Powered Robots Run Amok</title>
   <link href="http://example.org/2003/12/13/atom03"/>
   <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
   <updated>2003-12-13T18:30:02Z</updated>
   <summary>Some text.</summary>
 </entry>
 
</feed>
*/

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
if (state->state == 0)
	{
	state->state = 1;
	state->mutationsPtr = &state->state;
	}

NSUInteger theObjectCount = 0;

int theReturnCode = xmlTextReaderRead(self.reader);
while (theObjectCount != len && theReturnCode == 1 && self.error == NULL)
	{
	const int theNodeType = xmlTextReaderNodeType(self.reader);

	if (theNodeType == XML_READER_TYPE_ELEMENT)
		{
		NSDictionary *theObject = NULL;

		const xmlChar *theNodeName = xmlTextReaderConstLocalName(self.reader);
		EAtomElementNameCode theCode = CodeForAtomElementName(theNodeName);
		switch (theCode)
			{
			case AtomElementNameCode_Atom:
				theObject = [self dictionaryForAtomElement];
				break;
			case AtomElementNameCode_Entry:
//				theObject = self.currentItem = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:FeedDictinaryType_Entry] forKey:@"type"];
//				[self updateAttributesOfItem:self.currentItem];
				break;
			}
		if (theObject)
			stackbuf[theObjectCount++] = theObject;
		}

	theReturnCode = xmlTextReaderRead(self.reader);
	}

state->itemsPtr = stackbuf;

return(theObjectCount);
}

#pragma mark -

- (NSDictionary *)dictionaryForAtomElement
{
NSMutableDictionary *theDictionary = [NSMutableDictionary dictionary];
xmlNodePtr theNode = xmlTextReaderCurrentNode(self.reader);
xmlNodePtr theCurrentNode = theNode->children;
while (theCurrentNode != NULL)
	{
	if (theCurrentNode->type == XML_ELEMENT_NODE)
		{
		const xmlChar *theElementName = theCurrentNode->name;
		const EAtomElementNameCode theNameCode = CodeForAtomElementName(theElementName);
		switch (theNameCode)
			{
			case AtomElementNameCode_Title:
				{
				NSString *theContent = [NSString stringWithUTF8String:(const char *)xmlNodeGetContent(theCurrentNode)];
				[theDictionary setObject:theContent forKey:@"title"];
				}
				break;
			case AtomElementNameCode_Subtitle:
				{
				NSString *theContent = [NSString stringWithUTF8String:(const char *)xmlNodeGetContent(theCurrentNode)];
				[theDictionary setObject:theContent forKey:@"subtitle"];
				}
				break;
			case AtomElementNameCode_Link:
				{
				// TODO there will be multiple links. Need to make sure we get the right ones.
				NSString *theContent = [NSString stringWithUTF8String:(const char *)xmlNodeGetContent(theCurrentNode)];
				[theDictionary setObject:theContent forKey:@"link"];
				}
				break;
			case AtomElementNameCode_Updated:
				{
				// TODO there will be multiple links. Need to make sure we get the right ones.
				NSString *theContent = [NSString stringWithUTF8String:(const char *)xmlNodeGetContent(theCurrentNode)];

				[theDictionary setObject:theContent forKey:@"updated"];
				}
				break;
			default:
				{
				}
				break;
			}
		}
	
	theCurrentNode = theCurrentNode->next;
	}
return(theDictionary);
}


@end

static void MyXMLTextReaderErrorFunc(void *arg, const char *msg, xmlParserSeverities severity, xmlTextReaderLocatorPtr locator)
{
NSLog(@"ERROR: %d", severity);
if (severity >= XML_PARSER_SEVERITY_ERROR)
	{
	CAtomFeedDeserializer *theFeedDeserializer = (CAtomFeedDeserializer *)arg;

	NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSString stringWithUTF8String:msg], NSLocalizedDescriptionKey,
		NULL
		];

	NSError *theError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-1 userInfo:theUserInfo];
	theFeedDeserializer.error = theError;
	}
}
