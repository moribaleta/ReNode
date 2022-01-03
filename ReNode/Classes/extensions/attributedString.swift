//
//  attributedString.swift
//  ReactiveNodeSample
//
//  Created by Gabriel Mori Baleta on 8/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit


private struct AttributedStringContainer {

    static var      instance                : AttributedStringContainer = .init()

    private(set)
    var             attribute_label         : [ String : AnyObject ]

    private(set)
    var             attribute_data          : [ String : AnyObject ]


    private(set)
    var             attribute_sectionLabel  : [ String : AnyObject ]


    private(set)
    var             attribute_boldData      : [ String : AnyObject ]

    
    private(set)
    var             attribute_boldLight     : [ String : AnyObject ]
    
    private(set)
    var             attribute_italic        : [ String : AnyObject ]

    init            () {

        attribute_label         = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.systemFont(ofSize: 12),
                                    convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : Common.color.disabled_text_default.uicolor ]

        attribute_data          = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.systemFont(ofSize: 14),
                                    convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : Common.color.textbody.uicolor ]

        attribute_sectionLabel  = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.systemFont(ofSize: 16, weight: .bold),
        convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : Common.color.textbody.uicolor ]

        attribute_boldData      = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.systemFont(ofSize: 14, weight: .medium),
                                    convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : Common.color.textbody.uicolor ]
        
        attribute_boldLight     = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.systemFont(ofSize: 14, weight: .medium),
                                    convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : Common.color.label.uicolor ]
        
        attribute_italic        = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.italicSystemFont(ofSize: 14)]
        
    }
}

extension NSAttributedString {

    public convenience init(asHeader        text: String, color: UIColor = UIColor.black) {

        self.init(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.systemFont(ofSize: 20),//UIFont.systemFont(ofSize: <#T##CGFloat#>)(with: 20)!,
                                              convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : color ]))
    }

    public convenience init(asSectionLabel  text: String) {

        self.init(string: text,
                  attributes: convertToOptionalNSAttributedStringKeyDictionary(AttributedStringContainer.instance.attribute_sectionLabel))
    }


    public convenience init(asLabel         text: String, upper: Bool = true) {

        self.init(string: upper ? text.uppercased() : text,
                  attributes: convertToOptionalNSAttributedStringKeyDictionary(AttributedStringContainer.instance.attribute_label))
    }


    public convenience init(asData          text: String) {

        self.init(string: text,
                  attributes: convertToOptionalNSAttributedStringKeyDictionary(AttributedStringContainer.instance.attribute_data))
    }

    public convenience init(asData          text: String, with color: UIColor) {

        self.init(string: text,
                  attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.systemFont(ofSize: 14), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : color ]))
    }
    
    
    public convenience init(asData          text: String, size: CGFloat) {
        
        self.init(string: text,
                  attributes: [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: size) ])
    }

    public convenience init(asBoldData      text: String) {

        self.init(string: text,
                  attributes: convertToOptionalNSAttributedStringKeyDictionary(AttributedStringContainer.instance.attribute_boldData))
    }
    

    public convenience init(asAction        text: String) {

        self.init(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary(
                    [
                        convertFromNSAttributedStringKey(NSAttributedString.Key.font)               : UIFont(),
                        convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)    : Common.baseColor.blue.uicolor
                    ]))
    }

    public convenience init(asCommitAction  text: String) {

        self.init(string: text.uppercased(), attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont(),
                                                                                                            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : Common.baseColor.green.uicolor ]))
    }

    public convenience init(asDisabled      text: String) {

        self.init(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary([ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont(),
                                                                                               convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : Common.color.disabled_text_default.uicolor]))
    }

    /// bold font with light color
    public convenience init(asBoldLight     text: String) {
        
        self.init(string: text,
                  attributes: convertToOptionalNSAttributedStringKeyDictionary(AttributedStringContainer.instance.attribute_boldLight))
    }
    
    public convenience init(asItalic     text: String) {
        
        self.init(string: text,
                  attributes: convertToOptionalNSAttributedStringKeyDictionary(AttributedStringContainer.instance.attribute_italic))
    }


    public func foreground(_ color: UIColor) -> NSAttributedString {

        var attrib          = convertFromNSAttributedStringKeyDictionary(self.attributes(at: 0, effectiveRange: nil))

        attrib[convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)] = color

        return NSAttributedString(string: self.string, attributes: convertToOptionalNSAttributedStringKeyDictionary(attrib))
    }

    public func aligned(_ alignment: NSTextAlignment) -> NSAttributedString {
        guard self.string.count > 0 else {
            return self
        }
        
        var attrib          = convertFromNSAttributedStringKeyDictionary(self.attributes(at: 0, effectiveRange: nil))

        let parag           = NSMutableParagraphStyle()
            parag.alignment = alignment

        attrib[convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle)] = parag

        return NSAttributedString(string: self.string, attributes: convertToOptionalNSAttributedStringKeyDictionary(attrib))
    }
    
    /**
        adds underline to the attributedstring
     */
    public func underlined() -> NSAttributedString {
        guard self.string.count > 0 else {
            return self
        }
        var attrib  = convertFromNSAttributedStringKeyDictionary(self.attributes(at: 0, effectiveRange: nil))
        attrib[convertFromNSAttributedStringKey(NSAttributedString.Key.underlineStyle)] = NSUnderlineStyle.single.rawValue
        return NSAttributedString(string: self.string, attributes: convertToOptionalNSAttributedStringKeyDictionary(attrib))
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKeyDictionary(_ input: [NSAttributedString.Key: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}



let color_search_match = UIColor.hex("#ff9c3a")//(hexString: "#ff9c3a")

extension NSAttributedString {
    public func makeRequired () -> NSAttributedString {
        
        let mString = NSMutableAttributedString.init(attributedString: self)
        
        let asterisk = NSAttributedString.init(string: " *",
                                               attributes: [ NSAttributedString.Key.font : UIFont(),
                                                             NSAttributedString.Key.foregroundColor : Common.baseColor.red.uicolor ]
        )
        
        mString.append(asterisk)
        
        return mString
    }
    
    
    public func makeRequired(isRequired: Bool = true) -> NSAttributedString {
        
        guard isRequired else {return self}
        
        let mString = NSMutableAttributedString.init(attributedString: self)
        
        let asterisk = NSAttributedString.init(string: " *",
                                               attributes: [ NSAttributedString.Key.font : UIFont(), //UIFont(,
                                                             NSAttributedString.Key.foregroundColor : UIColor.red ]
        )
        
        mString.append(asterisk)
        
        return mString
    }
    
    public func highlight(_ searchString: String) -> NSAttributedString {
        
        guard searchString.isEmpty == false else {
            return self
        }
        
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.highlighted(searchString)
        return mutable
    }
    
    
//    /**
//        converts string to as a link
//     */
//    public func setAsLink() -> NSAttributedString {
//        let linkattr    = NSMutableAttributedString(string      : self.string,
//                                                    attributes  : [
//                                                        NSAttributedString.Key.link: URL(string: self.string)!
//                                                    ])
//
//        let mString     = NSMutableAttributedString.init(attributedString: self)
//        mString.append(linkattr)
//        return mString
//    }
    
}



extension NSMutableAttributedString {
    
    func highlighted(_ searchString: String) {
        
        let baseString = self.string
        
        if let regex = try? NSRegularExpression(pattern: searchString, options: .caseInsensitive) {
            for match in regex.matches(in: baseString, options: [], range: NSRange(location: 0, length: baseString.utf16.count)) {
                self.addAttributes([NSAttributedString.Key.foregroundColor : color_search_match], range: match.range)
                print(match.range)
            }
        }
    }
}
