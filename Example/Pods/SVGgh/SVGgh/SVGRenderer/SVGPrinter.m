//
//  SVGRenderer+Printing.m
//  SVGgh
// The MIT License (MIT)

//  Copyright (c) 2011-2014 Glenn R. Howes

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
//  Created by Glenn Howes on 2/4/14.
//

#import "SVGPrinter.h"
#import "SVGgh.h"
#import "SVGtoPDFConverter.h"


@implementation SVGPrinter
+(void) printRenderer:(SVGRenderer*)renderer  withJobName:(NSString*)jobName withCallback:(printingCallback_t)callback
{
    [self printRenderer:renderer withJobName:jobName withCallback:^(NSError * _Nullable error, PrintingResults printingResult) {
        callback(error, printingResult);
    }];
}

#if TARGET_OS_OSX

#else
+(void) printRenderer:(SVGRenderer*)renderer  withJobName:(NSString*)jobName fromAnchorView:(UIView*)anchorView withCallback:(printingCallback_t)callback
{
#if !TARGET_OS_TV
    [SVGtoPDFConverter createPDFFromRenderer:renderer intoCallback:^(NSData *pdfData)
    {
        if(pdfData.length)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIPrintInteractionController* printController = [UIPrintInteractionController sharedPrintController];
                if(printController != nil)
                {
                    UIPrintInfo* printerInfo = [UIPrintInfo printInfo];
                    printerInfo.outputType = UIPrintInfoOutputGeneral;
                    printerInfo.orientation = UIPrintInfoOrientationPortrait;
                    printerInfo.jobName = jobName;
                    printController.printInfo = printerInfo;
                    printController.printingItem = pdfData;
                    
                    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && anchorView)
                    {
                        [printController presentFromRect:anchorView.bounds inView:anchorView animated:YES
                                       completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
                                           if(completed && error != nil)
                                           {
                                               callback(error, kPrintingErrorResult);
                                           }
                                           else if(completed)
                                           {
                                               callback(nil, kSuccessfulPrintingResult);
                                           }
                                       }];

                    }
                    else
                    {
                        [printController presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
                            if(completed && error != nil)
                            {
                                callback(error, kPrintingErrorResult);
                            }
                            else if(completed)
                            {
                                callback(nil, kSuccessfulPrintingResult);
                            }
                        }];
                    }
                }
                else
                {
                    callback(nil, kCouldntInterfaceWithPrinterResult);
                }
            }];
        }
        else
        {
            callback(nil, kCouldntCreatePrintingDataResult);
        }
    }];
#else 
    NSLog(@"Printing not supported on tvOS");
#endif
}
#endif
@end
