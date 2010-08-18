//
//  CObjectTranscoder.h
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

#import <Foundation/Foundation.h>


@interface CObjectTranscoder : NSObject {
	Class targetObjectClass;
	NSDictionary *propertyNameMappings;
	NSDictionary *invertedPropertyNameMappings;
}

@property (readwrite, assign) Class targetObjectClass;
@property (readwrite, retain) NSDictionary *propertyNameMappings;
@property (readwrite, retain) NSDictionary *invertedPropertyNameMappings;

- (id)initWithTargetObjectClass:(Class)inTargetObjectClass;

- (NSDictionary *)dictionaryForObjectUpdate:(id)inObject withPropertiesInDictionary:(NSDictionary *)inDictionary error:(NSError **)outError;
- (BOOL)updateObject:(id)inObject withPropertiesInDictionary:(NSDictionary *)inDictionary error:(NSError **)outError;

- (id)transformObject:(id)inObject toObjectOfClass:(Class)inTargetClass error:(NSError **)outError;

@end
