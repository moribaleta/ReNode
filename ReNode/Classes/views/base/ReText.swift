//
//  CommonText.swift
//  
//
//  Created by Gabriel Mori Baleta on 8/6/21.
//
import Foundation
import UIKit
import AsyncDisplayKit

public enum ReTextType {
    
    ///displayText: size: 24 weight: .medium color_ref: .header_title
    case displayText
    ///.title: size: 21 weight: .medium color_ref: .header_title
    case title
    ///.subtitle: size: 18 weight: .medium color_ref: .header_title
    case subtitle
    ///.titleText: size: 15 weight: .medium color_ref:  .textbody
    case titleText
    ///.templateButton: size 15 weight: .medium color_ref: .template_text
    case templateButton
    ///.warningTitle size 15 weight medium color_ref: warning
    case warningTitle
    ///case warningText: size: 15 weight: .regular color_ref:  .warning
    case warningText
    ///case bodyText  size: 15 weight: .regular color_ref:  .textbody
    case bodyText
    ///case disabledButton size: 15 weight: .regular color_ref:  .textbody
    case disabledButton
    ///case disabledText size: 15 weight: .medium  color_ref: .disabled_text_default
    case disabledText
    ///case pillText  size: 12 weight: .medium  color_ref: .textbody
    case pillText
    ///case links  size: 12 weight: .medium  color_ref: .template_text
    case links
    ///case label  size: 12 weight: .regular color_ref:  .textbody
    case label
    ///case sublabel  size: 12 weight: .regular color_ref:  .label
    case sublabel
    ///warning Label  size: 12 weight: .regular color_ref:  .warning
    case warningLabel
    ///titleLabel  size: 12 weight: .regular color_ref:  .label
    case titleLabel
    ///placeholder  size: 15 weight: .regular isItalic: italic color_ref:   .label
    case placeholder
    
    
    public var size : CGFloat {
        switch self {
        case .displayText:
            return 24
        case .title:
            return 21
        case .subtitle:
            return 18
        case .titleText:
            return 15
        case .templateButton:
            return 15
        case .warningTitle:
            return 15
        case .warningText:
            return 15
        case .bodyText:
            return 15
        case .disabledButton:
            return 15
        case .disabledText:
            return 15
        case .pillText:
            return 12
        case .links:
            return 12
        case .label:
            return 12
        case .sublabel:
            return 12
        case .warningLabel:
            return 12
        case .titleLabel:
            return 12
        case .placeholder:
            //return 12
            return 15
        }
    }
    
    public var fontWeight : UIFont.Weight {
        switch self {
        case .displayText:
            return .medium
        case .title:
            return .medium
        case .subtitle:
            return .medium
        case .titleText:
            return .medium
        case .templateButton:
            return .medium
        case .warningTitle:
            return .medium
        case .warningText:
            return .regular
        case .bodyText:
            return .regular
        case .disabledButton:
            return .regular
        case .disabledText:
            return .medium
        case .pillText:
            return .medium
        case .links:
            return .medium
        case .label:
            return .regular
        case .sublabel:
            return .regular
        case .warningLabel:
            return .regular
        case .titleLabel:
            return .regular
        case .placeholder:
            return .regular
        }
    }
    
    public var isItalic : Bool {
        return self == .placeholder
    }
    
    public var color : Common.color {
        switch self {
        case .displayText:
            return .header_title
        case .title:
            return .header_title
        case .subtitle:
            return .header_title
        case .titleText:
            return .textbody
        case .templateButton:
            return .template_text
        case .warningTitle:
            return .warning
        case .warningText:
            return .warning
        case .bodyText:
            return .textbody
        case .disabledButton:
            return .disabled_text_default
        case .disabledText:
            return .disabled_text_default
        case .pillText:
            return .textbody
        case .links:
            return .template_text
        case .label:
            return .textbody
        case .sublabel:
            return .label
        case .warningLabel:
            return .warning
        case .titleLabel:
            return .label
        case .placeholder:
            return .label
        }
    }
}

open class ReTextNode : ASTextNode {
    
    var attribute   : ReTextType = .bodyText
    var text        : String = ""
    var fontSize    : CGFloat?
    var color       : UIColor?
    var highlight   : String?
    var fontWeight  : UIFont.Weight?
    
    /**
     is a ASTextNode that implements attributed text from ReTextType
     - parameters :
     - text: String to be load
     - attribute: ReTextType used to describe the text to be displayed
     - size:
     - overrides size from attribute
     - Optional
     */
    required convenience public init(_ text: String, attribute: ReTextType = .bodyText, size: CGFloat? = nil, fontWeight: UIFont.Weight? = nil, color: UIColor? = nil, highlight: String? = nil, isItalic: Bool? = nil, isRequired: Bool = false) {
        self.init()
        self.text = text
        self.attribute  = attribute
        self.fontSize   = size ?? attribute.size
        self.highlight  = highlight
        self.fontWeight = fontWeight
        self.color      = color
        self.setText(text,
                     attribute  : attribute,
                     size       : size,
                     fontWeight : fontWeight,
                     color      : color,
                     highlight  : highlight,
                     isItalic   : isItalic,
                     isRequired : isRequired)
    }
    
    public func setText(_ text: String, attribute : ReTextType = .bodyText, size: CGFloat? = nil, fontWeight: UIFont.Weight? = nil, color: UIColor? = nil, highlight: String? = nil,  isItalic: Bool? = nil,  isRequired: Bool = false) {
        self.text = text
        self.attribute = attribute
        self.fontSize = size ?? attribute.size
        self.color  = color ?? attribute.color.uicolor
        
        var attributedDict : [NSAttributedString.Key : Any] = [:]
        
        let font = UIFont.systemFont(ofSize: self.fontSize ?? attribute.size, weight: fontWeight ?? attribute.fontWeight).italize(isItalic ?? false)
        
        attributedDict[.font]   = font
        attributedDict[.foregroundColor]    = color ?? attribute.color.uicolor
        
        self.attributedText = NSAttributedString(string: self.text, attributes: attributedDict).highlight(highlight ?? "").makeRequired(isRequired: isRequired)
    }
    
    /*
     open override func didLoad() {
     super.didLoad()
     self.setText(text: self.text, attribute: self.attribute, size: self.fontSize)
     }
     */
}

extension Common {
    
    public static func attributedString(_ text: String, attribute : ReTextType = .bodyText, size: CGFloat? = nil, fontWeight: UIFont.Weight? = nil, color: UIColor? = nil, highlight: String? = nil,  isItalic: Bool? = nil) -> NSAttributedString {
        
        var attributedDict : [NSAttributedString.Key : Any] = [:]
        
        let font                            = UIFont.systemFont(ofSize: size ?? attribute.size, weight: fontWeight ?? attribute.fontWeight).italize(isItalic ?? false)
        attributedDict[.font]               = font
        attributedDict[.foregroundColor]    = color ?? attribute.color.uicolor
        
        return NSAttributedString(string: text, attributes: attributedDict).highlight(highlight ?? "")
    }
    
    public static func attributedString(_ text: String, attribute : ReTextType = .bodyText, size: CGFloat? = nil, fontWeight: UIFont.Weight? = nil, color: UIColor? = nil, highlight: String? = nil,  isItalic: Bool? = nil, maxLength: Int? = nil) -> NSAttributedString {
        
        var attributedDict : [NSAttributedString.Key : Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let font                            = UIFont.systemFont(ofSize: size ?? attribute.size, weight: fontWeight ?? attribute.fontWeight)
        attributedDict[.font]               = font
        attributedDict[.foregroundColor]    = color ?? attribute.color.uicolor
        attributedDict[.paragraphStyle]     = paragraphStyle
        
        let maxLength = maxLength ?? Int.max < text.count ? (maxLength ?? Int.max) : text.count
        
        let range = NSRange(location: 0, length: maxLength)
        let attr  = NSAttributedString(string: text, attributes: attributedDict).highlight(highlight ?? "")
        
        return attr.attributedSubstring(from: range)
    }
}


public extension UIFont {
    
    func italize(_ isItalize: Bool) -> UIFont {
        isItalize ?
            UIFont.italicSystemFont(ofSize: self.pointSize):
            self
    }
    
}

