//
//  GHCSSStyle.m
//  SVGgh
//
// The MIT License (MIT)

//  Copyright (c) 2016 Glenn R. Howes

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//
//  Created by Glenn Howes on 3/19/16.

#import "GHCSSStyle.h"

@implementation GHCSSStyle
+(NSDictionary<NSString*, GHCSSStyle*>*) stylesForString:(NSString*)css
{
    NSDictionary<NSString*, GHCSSStyle*>* result = [NSDictionary  new];
    
    
    
    return result;
}
+(NSString*) attributeNamed:(NSString*)attributeName classes:(nullable NSArray<NSString*>*)listOfClasses entityName:(nullable NSString*)entityName pseudoClass:(CSSPseudoClassFlags)pseudoClassFlags forStyles:(NSDictionary<NSString*, GHCSSStyle*>*) cssStyles
{
    NSString* result = nil;
    GHCSSStyle* entityStyle = nil;
    if(entityName.length)
    {
        entityStyle = [cssStyles valueForKey:entityName];
        if(entityStyle)
        {
            for(NSString* aClass in listOfClasses)
            {
                GHCSSStyle* classEntityStyle = [entityStyle.subClasses valueForKey:aClass];
                if(classEntityStyle != nil && classEntityStyle.pseudoClassFlags & pseudoClassFlags) // should this be & or == ?
                {
                    result = [classEntityStyle.attributes valueForKey:attributeName];
                }
            }
        }
    }
    
    if(result == nil)
    {
        for(NSString* aClass in listOfClasses)
        {
            GHCSSStyle* classStyle = [cssStyles valueForKey:aClass];
            if(classStyle && classStyle.pseudoClassFlags & pseudoClassFlags)  // should this be & or == ?
            {
                result = [classStyle.attributes valueForKey:attributeName];
            }
        }
    }
    
    if(result == nil)
    {
        result = [entityStyle valueForKey:attributeName];
    }
    
    return result;
}
@end
