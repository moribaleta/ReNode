//
//  SVGRenderer.h
//  SVGgh
// The MIT License (MIT)

//  Copyright (c) 2011-2018 Glenn R. Howes

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
//  Created by Glenn Howes on 1/12/11.


#if defined(__has_feature) && __has_feature(modules)
    @import Foundation;
    @import UIKit;
#else
    #import <Foundation/Foundation.h>
    #import <UIKit/UIKit.h>
#endif

#import "CrossPlatformImage.h"
#import "SVGParser.h"
#import "GHRenderable.h"
#import "SVGContext.h"
#import "GHCSSStyle.h"

NS_ASSUME_NONNULL_BEGIN

/*! @brief a class capable of rendering itself into a core graphics context
*/
@interface SVGRenderer : SVGParser<SVGContext, GHRenderable>

/*! @property viewRect
 * @brief a set of flags that allow the dynamic manipulation of rendering styles (for instance, a focused tvOS image could use kPseudoClassFocused)
 */
@property (assign, nonatomic)   CSSPseudoClassFlags cssPseudoClass;

/*! @property viewRect
* @brief the intrinsic rect declared in the SVG document being rendered
*/
@property (nonatomic, readonly)         CGRect	viewRect;

/*! @brief a queue where it is convenient to renders when the main queue is not necessary
* @return a shared operation queue
*/
+(NSOperationQueue*) rendererQueue;

/*! @brief init method which takes a URL reference to a .svg file
 * @param url a reference to a standard .svg or .svgz file
 */
-(instancetype)initWithContentsOfURL:(NSURL *)url;

/*! @brief init method which takes a input stream from a SVG source
 * @param inputStream a reference to a standard .svg or .svgz file
 */
-(instancetype)initWithInputStream:(NSInputStream *)inputStream;

/*! @brief init method which the name of a resource based SVG
 * @param resourceName string giving the name of the resource. This may include a file extension, if ommitted `svg` will be used.
 * @param bundle optional bundle to look in
 * @commment might be from XCAsset data
 */
-(nullable  instancetype) initWithResourceName:(NSString*)resourceName inBundle:(nullable NSBundle*)bundle;

/*! @brief init method which takes an SVG document which already exists as a string
 * @param utf8String string containing the SVG document
 */
-(instancetype)initWithString:(NSString*)utf8String;

/*! @brief init method which takes an SVG document which already exists as a string
 * @param assetName string which will be based to constructor of NSDataAsset
 * @param bundle optional bundle, if nil, the main bundle will be used.
 */
-(nullable  instancetype) initWithDataAssetNamed:(NSString*)assetName withBundle:(nullable NSBundle*)bundle API_AVAILABLE(ios(9.0), macos(10.11), tvos(9.0), watchos(2.0));


/*! @brief not allowing a standard init method
 */
-(instancetype) init __attribute__((unavailable("init not available")));

/*! @brief draw the SVG
* @param quartzContext context into which to draw, could be a CALayer, a PDF, an offscreen bitmap, whatever
*/
-(void)renderIntoContext:(CGContextRef)quartzContext;

/*! @brief try to locate an object that's been tapped
* @param testPoint a point in the coordinate system of this renderer
* @return an object which implements the GHRenderable protocol
*/
-(nullable id<GHRenderable>) findRenderableObject:(CGPoint)testPoint;

/*! @brief make a scaled image from the renderer
 * @param maximumSize the maximum dimension in points to render into.
 * @param scale same as a UIWindow's scale
 * @return a UIImage or NSImage depending on platform
 */
#if TARGET_OS_OSX
-(nullable NSImage*) asImageWithSize:(CGSize)maximumSize andScale:(CGFloat)scale;
#else
-(UIImage*)asImageWithSize:(CGSize)maximumSize andScale:(CGFloat)scale;
#endif
@end

NS_ASSUME_NONNULL_END


