//
//  CRSSFeedDeserializer.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/8/08.
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

#import "CRSSFeedDeserializer.h"

#include <libxml/xmlreader.h>
#include "RSSKeywords.h"

#import "NSDate_InternetDateExtensions.h"
#import "CXMLNode_PrivateExtensions.h"
#import "CXMLElement.h"

static void MyXMLTextReaderErrorFunc(void *arg, const char *msg, xmlParserSeverities severity, xmlTextReaderLocatorPtr locator);

@interface CRSSFeedDeserializer ()

@property (readwrite, nonatomic, assign) xmlTextReaderPtr reader;
@property (readwrite, nonatomic, retain) NSError *error;

- (void)updateAttributesOfChannel:(NSMutableDictionary *)inChannel;
- (void)updateAttributesOfItem:(NSMutableDictionary *)inItem;

@end

#pragma mark -

@implementation CRSSFeedDeserializer

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

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
if (state->state == 0)
	{
	state->state = 1;
	state->mutationsPtr = &state->state;
	}

NSMutableDictionary *theCurrentFeed = NULL;

NSUInteger theObjectCount = 0;
int theReturnCode = xmlTextReaderRead(self.reader);
while (theObjectCount < len && theReturnCode == 1 && self.error == NULL)
	{
	const int theNodeType = xmlTextReaderNodeType(self.reader);

	if (theNodeType == XML_READER_TYPE_ELEMENT)
		{
		NSMutableDictionary *theDictionary = NULL;
		const xmlChar *theNodeName = xmlTextReaderConstLocalName(self.reader);
		int theCode = CodeForElementName(theNodeName);
		switch (theCode)
			{
			case RSSElementNameCode_RSS:
				theDictionary = theCurrentFeed = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:FeedDictionaryType_Feed] forKey:@"type"];
				break;
			case RSSElementNameCode_Channel:
				[self updateAttributesOfChannel:theCurrentFeed];
				break;
			case RSSElementNameCode_Item:
				theDictionary = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:FeedDictinaryType_Entry] forKey:@"type"];
				[self updateAttributesOfItem:theDictionary];
				break;
			}

		if (theDictionary)
			{
			stackbuf[theObjectCount++] = theDictionary;
			}
		}

	if (theObjectCount >= len)
		break;

	theReturnCode = xmlTextReaderRead(self.reader);
	}

state->itemsPtr = stackbuf;

return(theObjectCount);
}

- (void)updateAttributesOfChannel:(NSMutableDictionary *)inChannel
{
xmlNodePtr theNode = xmlTextReaderCurrentNode(self.reader);
xmlNodePtr theCurrentNode = theNode->children;
while (theCurrentNode != NULL)
	{
	if (theCurrentNode->type == XML_ELEMENT_NODE)
		{
		const xmlChar *theElementName = theCurrentNode->name;
		const ERSSElementNameCode theNameCode = CodeForElementName(theElementName);
		switch (theNameCode)
			{
			case RSSElementNameCode_Title:
				{
				xmlChar *theContentBytes = xmlNodeGetContent(theCurrentNode);
				NSString *theContent = [NSString stringWithUTF8String:(const char *)theContentBytes];
				theContent = [theContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				[inChannel setObject:theContent forKey:@"title"];
				xmlFree(theContentBytes);
				}
				break;
			case RSSElementNameCode_Link:
				{
				xmlChar *theContentBytes = xmlNodeGetContent(theCurrentNode);
				NSString *theContent = [NSString stringWithUTF8String:(const char *)theContentBytes];
				theContent = [theContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				NSURL *theLink = [NSURL URLWithString:theContent];
				[inChannel setObject:theLink forKey:@"link"];
				xmlFree(theContentBytes);
				}
				break;
			case RSSElementNameCode_Description:
				{
				xmlChar *theContentBytes = xmlNodeGetContent(theCurrentNode);
				NSString *theContent = [NSString stringWithUTF8String:(const char *)theContentBytes];
				theContent = [theContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				[inChannel setObject:theContent forKey:@"subtitle"];
				xmlFree(theContentBytes);
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
}

- (void)updateAttributesOfItem:(NSMutableDictionary *)inItem
{
xmlNodePtr theNode = xmlTextReaderExpand(self.reader);
xmlNodePtr theCurrentNode = theNode->children;
while (theCurrentNode != NULL && self.error == NULL)
	{
	if (theCurrentNode->type == XML_ELEMENT_NODE)
		{
		const xmlChar *theElementName = theCurrentNode->name;
		const ERSSElementNameCode theNameCode = CodeForElementName(theElementName);
		switch (theNameCode)
			{
			case RSSElementNameCode_Title:
				{
				xmlChar *theContentBytes = xmlNodeGetContent(theCurrentNode);
				NSString *theContent = [NSString stringWithUTF8String:(const char *)theContentBytes];
				theContent = [theContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if (theContent)
				[inItem setObject:theContent forKey:@"title"];
				xmlFree(theContentBytes);
				}
				break;
			case RSSElementNameCode_Link:
				{
				xmlChar *theContentBytes = xmlNodeGetContent(theCurrentNode);
				NSString *theContent = [NSString stringWithUTF8String:(const char *)theContentBytes];

				theContent = [theContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

				NSURL *theLink = [NSURL URLWithString:theContent];
				if (theLink)
					[inItem setObject:theLink forKey:@"link"];
				xmlFree(theContentBytes);
				}
				break;
			case RSSElementNameCode_Description:
				{
				xmlChar *theContentBytes = xmlNodeGetContent(theCurrentNode);
				NSString *theContent = [NSString stringWithUTF8String:(const char *)theContentBytes];
				theContent = [theContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if (theContent)
					[inItem setObject:theContent forKey:@"content"];
				xmlFree(theContentBytes);
				}
				break;
			case RSSElementNameCode_PubDate:
				{
				xmlChar *theContentBytes = xmlNodeGetContent(theCurrentNode);
				NSString *theContent = [NSString stringWithUTF8String:(const char *)theContentBytes];
				theContent = [theContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				NSDate *theDate = [NSDate dateWithRFC2822String:theContent];
				if (theDate)
					[inItem setObject:theDate forKey:@"updated"];
				xmlFree(theContentBytes);
				}
				break;
			case RSSElementNameCode_GUID:
				{
				xmlChar *theContentBytes = xmlNodeGetContent(theCurrentNode);
				NSString *theContent = [NSString stringWithUTF8String:(const char *)theContentBytes];
				theContent = [theContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if (theContent)
					[inItem setObject:theContent forKey:@"identifier"];
				xmlFree(theContentBytes);
				}
				break;
			default:
				{
				if (strcmp((const char *)theElementName, "updated") == 0 && [inItem objectForKey:@"updated"] == NULL)
					{
					xmlChar *theContentBytes = xmlNodeGetContent(theCurrentNode);
					NSString *theContent = [NSString stringWithUTF8String:(const char *)theContentBytes];
					theContent = [theContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					NSDate *theDate = [NSDate dateWithRFC2822String:theContent];
					if (theDate)
						[inItem setObject:theDate forKey:@"updated"];
					xmlFree(theContentBytes);
					}
				else if (strcmp((const char *)theElementName, "thumbnail") == 0)
					{
					NSLog(@"THUMBNAIL!");
					
					CXMLElement *theElement = [CXMLElement nodeWithLibXMLNode:theCurrentNode freeOnDealloc:NO];
					NSLog(@"%@", theElement);
					NSString *theThumbnailURLString = [[theElement attributeForName:@"url"] stringValue];
					[inItem setObject:theThumbnailURLString forKey:@"thumbnailURL"];					
					}
				else
					{
					xmlNodePtr theNodeCopy = xmlCopyNode(theCurrentNode, 1);
					
					CXMLElement *theElement = [CXMLElement nodeWithLibXMLNode:theNodeCopy freeOnDealloc:YES];
					NSMutableDictionary *theDictionary = [inItem objectForKey:@"extraXML"];
					if (theDictionary == NULL)
						{
						theDictionary = [NSMutableDictionary dictionaryWithObject:theElement forKey:theElement.name];
						[inItem setObject:theDictionary forKey:@"extraXML"];
						}
					else
						{
						[theDictionary setObject:theElement forKey:theElement.name];
						}
					}
				}
				break;
			}
		}

	theCurrentNode = theCurrentNode->next;
	}

int theReturnCode = xmlTextReaderNext(self.reader);
NSAssert(theReturnCode == 1, @"");
}

@end

static void MyXMLTextReaderErrorFunc(void *arg, const char *msg, xmlParserSeverities severity, xmlTextReaderLocatorPtr locator)
{
NSLog(@"ERROR: %d (TODO)", severity);
if (severity >= XML_PARSER_SEVERITY_ERROR)
	{
	CRSSFeedDeserializer *theRSSFeedDeserializer = (CRSSFeedDeserializer *)arg;

	NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSString stringWithUTF8String:msg], NSLocalizedDescriptionKey,
		NULL
		];

	NSError *theError = [NSError errorWithDomain:kTouchRSSErrorDomain code:-1 userInfo:theUserInfo];
	theRSSFeedDeserializer.error = theError;
	}
}
