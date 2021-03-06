//
//  UIFont.swift
//  ReNode
//
//  Created by Mini on 1/6/22.
//

import Foundation
import UIKit

public extension UIFont {
    
    static var bundle : Bundle {
        Bundle(for: FASFontLoader.self)
    }
    
    static func icon(from font: Fonts, ofSize size: CGFloat) -> UIFont {
        /*let fontName = font.rawValue
        let fontNames = UIFont.fontNames(forFamilyName: font.rawValue)
        if !fontNames.contains(fontName)
        {
            FontLoader.loadFont(fontName)
        }
        return UIFont(name: fontName, size: size)!*/
        
        return FASFontLoader
            .loadCustomFont(
                family: font.rawValue,
                name: font.rawValue,
                fileName: "SeriousMD",
                type: "ttf",
                size: size,
                bundle: UIFont.bundle)
    }
    
    static func font(_ font: Fonts, ofSize size: CGFloat) -> UIFont {
        return UIFont(name: font.rawValue, size: size)!
    }
}
