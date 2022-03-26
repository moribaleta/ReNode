//
//  FontLoader.swift
//  ReNode
//
//  Created by Mini on 1/6/22.
//

import UIKit
import Foundation
import CoreText


public enum Fonts: String {
    case Roboto = "Roboto"
    case SeriousMD = "SeriousMD" // icon
}

class FontLoader: NSObject {
    class func loadFont(_ fontName: String) {
        let bundle = Bundle(for: FontLoader.self)
        let paths = bundle.paths(forResourcesOfType: "ttf", inDirectory: nil)
        var fontURL: NSURL?
        var error: Unmanaged<CFError>?

        paths.forEach {
            guard let filename = NSURL(fileURLWithPath: $0).lastPathComponent,
                filename.lowercased().range(of: fontName.lowercased()) != nil else {
                    return
            }

            fontURL = NSURL(fileURLWithPath: $0)
        }

        guard let fontURL = fontURL else {
                return
        }

        guard
            !CTFontManagerRegisterFontsForURL(fontURL, .process, &error),
            let unwrappedError = error,
            let nsError = (unwrappedError.takeUnretainedValue() as AnyObject) as? NSError else {

            return
        }

        let errorDescription: CFString = CFErrorCopyDescription(unwrappedError.takeUnretainedValue())

        NSException(name: NSExceptionName.internalInconsistencyException,
                    reason: errorDescription as String,
                    userInfo: [NSUnderlyingErrorKey: nsError]).raise()
    }
}



