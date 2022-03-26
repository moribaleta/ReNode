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
    var             attribute_label         : [ NSAttributedString.Key : AnyObject ]

    private(set)
    var             attribute_data          : [ NSAttributedString.Key : AnyObject ]


    private(set)
    var             attribute_sectionLabel  : [ NSAttributedString.Key : AnyObject ]


    private(set)
    var             attribute_boldData      : [ NSAttributedString.Key : AnyObject ]

    
    private(set)
    var             attribute_boldLight     : [ NSAttributedString.Key : AnyObject ]
    
    private(set)
    var             attribute_italic        : [ NSAttributedString.Key : AnyObject ]

    init            () {

        attribute_label         = [ .font : UIFont.systemFont(ofSize: 12),
                                    .foregroundColor : Common.color.disabled_text_default.uicolor ]

        attribute_data          = [ .font : UIFont.systemFont(ofSize: 14),
                                    .foregroundColor : Common.color.textbody.uicolor ]

        attribute_sectionLabel  = [ .font : UIFont.systemFont(ofSize: 16, weight: .bold),
                                    .foregroundColor : Common.color.textbody.uicolor ]

        attribute_boldData      = [ .font : UIFont.systemFont(ofSize: 14, weight: .medium),
                                    .foregroundColor : Common.color.textbody.uicolor ]
        
        attribute_boldLight     = [ .font : UIFont.systemFont(ofSize: 14, weight: .medium),
                                    .foregroundColor : Common.color.label.uicolor ]
        
        attribute_italic        = [ .font : UIFont.italicSystemFont(ofSize: 14) ]
        
    }
}

extension NSAttributedString {

    public convenience init(asHeader        text: String, color: UIColor = UIColor.black) {

        self.init(string: text, attributes: [.font : UIFont.systemFont(ofSize: 20), .foregroundColor : color])
    }

    public convenience init(asSectionLabel  text: String) {

        self.init(string: text,
                  attributes: AttributedStringContainer.instance.attribute_sectionLabel)
    }


    public convenience init(asLabel         text: String, upper: Bool = true) {

        self.init(string: upper ? text.uppercased() : text,
                  attributes: AttributedStringContainer.instance.attribute_label)
    }


    public convenience init(asData          text: String) {

        self.init(string: text,
                  attributes: AttributedStringContainer.instance.attribute_data)
    }

    public convenience init(asData          text: String, with color: UIColor) {

        self.init(string: text,
                  attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : color])
    }
    
    
    public convenience init(asData          text: String, size: CGFloat) {
        
        self.init(string: text,
                  attributes: [ .font : UIFont.systemFont(ofSize: size) ])
    }

    public convenience init(asBoldData      text: String) {

        self.init(string: text,
                  attributes: AttributedStringContainer.instance.attribute_boldData)
    }
    

    public convenience init(asAction        text: String) {

        self.init(string: text, attributes: [.font: UIFont(), .foregroundColor : Common.baseColor.blue.uicolor] )
    }

    public convenience init(asCommitAction  text: String) {

        self.init(string: text.uppercased(), attributes: [.font: UIFont(), .foregroundColor : Common.baseColor.green.uicolor ])
    }

    public convenience init(asDisabled      text: String) {

        self.init(string: text, attributes: [.font: UIFont(), .foregroundColor : Common.color.disabled_text_default.uicolor ])
    }

    /// bold font with light color
    public convenience init(asBoldLight     text: String) {
        
        self.init(string: text,
                  attributes: AttributedStringContainer.instance.attribute_boldLight)
    }
    
    public convenience init(asItalic     text: String) {
        
        self.init(string: text,
                  attributes: AttributedStringContainer.instance.attribute_italic)
    }

    public convenience init(asIcon          icon: Icon, iconSize size: CGFloat = 16, foreground color: UIColor = Common.color.textbody.uicolor) {
        let iconFont : UIFont   = UIFont.icon(from: Fonts.SeriousMD, ofSize: size)
        self.init(
           string: icon.rawValue,
           attributes: [
               NSAttributedString.Key.font             : iconFont,
               NSAttributedString.Key.foregroundColor  : color
           ])
    }
    
    public convenience init(asIcon          icon: Icon, iconSize size: CGFloat = 16, foreground color: CommonColorType) {
        let iconFont : UIFont   = UIFont.icon(from: Fonts.SeriousMD, ofSize: size)
        self.init(
           string: icon.rawValue,
           attributes: [
               NSAttributedString.Key.font             : iconFont,
               NSAttributedString.Key.foregroundColor  : color.uicolor
           ])
    }

    public func foreground(_ color: UIColor) -> NSAttributedString {

        var attrib          = self.attributes(at: 0, effectiveRange: nil)

        attrib[.foregroundColor] = color

        return NSAttributedString(string: self.string, attributes: attrib)
    }

    public func aligned(_ alignment: NSTextAlignment) -> NSAttributedString {
        guard self.string.count > 0 else {
            return self
        }
        
        var attrib          = self.attributes(at: 0, effectiveRange: nil)

        let parag           = NSMutableParagraphStyle()
            parag.alignment = alignment

        attrib[NSAttributedString.Key.paragraphStyle] = parag

        return NSAttributedString(string: self.string, attributes: attrib)
    }
    
    /**
        adds underline to the attributedstring
     */
    public func underlined() -> NSAttributedString {
        guard self.string.count > 0 else {
            return self
        }
        var attrib  = self.attributes(at: 0, effectiveRange: nil)
        attrib[.underlineStyle] = NSUnderlineStyle.single.rawValue
        return NSAttributedString(string: self.string, attributes: (attrib))
    }
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
