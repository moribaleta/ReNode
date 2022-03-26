//
//  UIColor.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation


public extension UIColor {
    ///converts uicolor to hexstring
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    
    ///converts string into a uicolor if the color is not valid it will return grey
    convenience init(hexString: String) {
        var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }

            if ((cString.count) != 6) {
                self.init(
                    red:    128,
                    green:  128,
                    blue:   128,
                    alpha:  1
                )
                return
            }

            var rgbValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)

            self.init(
                red:    CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green:  CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue:   CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha:  CGFloat(1.0)
            )
    }
}

