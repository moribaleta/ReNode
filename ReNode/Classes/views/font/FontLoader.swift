//
//  FontLoader.swift
//  ReNode
//
//  Created by Mini on 1/6/22.
//

import UIKit
import Foundation
import CoreText
import AVFoundation


public enum Fonts: String {
    case Roboto = "Roboto"
    case SeriousMD = "SeriousMD" // icon
}

class FontLoader: NSObject {
    
    static var loaded = false
    
    class func loadFont() {
        
        if loaded {
            return
        }
        loaded = true
        
        
        let bundle = Bundle(for: FontLoader.self)
        let paths = bundle.paths(forResourcesOfType: "ttf", inDirectory: nil)
        
        paths.forEach { path in
            let filename = NSURL(fileURLWithPath: path).lastPathComponent
            UIFont.registerFont(withFilenameString: filename!, bundle: bundle)
        }

    }
    
}

public extension UIFont {

    public static func registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        print("smd_registerFont \(filenameString)")
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }

        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }

        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }

        guard let font = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }

        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }

}



