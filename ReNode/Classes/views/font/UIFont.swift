//
//  UIFont.swift
//  ReNode
//
//  Created by Mini on 1/6/22.
//

import Foundation
import UIKit

public extension UIFont {
    static func icon(from font: Fonts, ofSize size: CGFloat) -> UIFont {
        let fontName = font.rawValue
        let fontNames = UIFont.fontNames(forFamilyName: font.rawValue)
        if !fontNames.contains(fontName)
        {
            FontLoader.loadFont(fontName)
        }
        return UIFont(name: fontName, size: size)!
    }
}
