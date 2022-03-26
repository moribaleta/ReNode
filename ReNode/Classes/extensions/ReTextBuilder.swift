//
//  ReTextBuilder.swift
//  
//
//  Created by Gabriel Mori Baleta on 12/22/21.
//

import Foundation
import UIKit

public protocol ReAttributedStringTrait {
    var representation: NSAttributedString { get }
}

@resultBuilder
public struct ReTextBuilder {
    
    public static func buildExpression(_ expression: ReAttributedStringTrait) -> ReAttributedStringTrait {
        expression
    }
    
    public static func buildExpression(_ expression: UIImage) -> ReAttributedStringTrait {
        ReAttributedStringTraits.Image(image: expression)
    }
    
    public static func buildExpression(_ expression: String) -> ReAttributedStringTrait {
        ReAttributedStringTraits.ReText(expression)
    }
    
    public static func buildExpression(_ expression: NSAttributedString) -> ReAttributedStringTrait {
        ReAttributedStringTraits.AttributedString(expression)
    }
    
    public static func buildBlock(_ components: ReAttributedStringTrait...) -> NSAttributedString {
        tell(NSMutableAttributedString()) {
            components.map { $0.representation }.forEach($0.append)
        }
    }
   
    
    public static func buildBlock(_ components: NSAttributedString?...) -> NSAttributedString {
        tell(NSMutableAttributedString()) {
            attribute in
            //components.filterNils().map { .init(attributedString: $0) }.forEach($0.append)
            components
                .compactMap{$0}
                .map{NSAttributedString.init(attributedString: $0)}
                .forEach(attribute.append)
        }
    }
}

public enum ReAttributedStringTraits {
    
    public struct AttributedString : ReAttributedStringTrait {
        public var representation: NSAttributedString {
            return self.attributedString
        }
        var attributedString : NSAttributedString
        
        public init(_ attributedString : NSAttributedString) {
            self.attributedString = attributedString
        }
    }
    
    public struct ReText : ReAttributedStringTrait {
        
        public var representation: NSAttributedString {
            self.text
        }
        
        var text : NSAttributedString
        
        public init(_ text: String, attribute : ReTextType = .bodyText, size: CGFloat? = nil, fontWeight: UIFont.Weight? = nil, color: UIColor? = nil, highlight: String? = nil,  isItalic: Bool? = nil, maxLength: Int? = nil) {
            self.text = Common.attributedString(
                text,
                attribute   : attribute,
                size        : size,
                fontWeight  : fontWeight,
                color       : color,
                highlight   : highlight,
                isItalic    : isItalic,
                maxLength   : maxLength)
        }
        
    }
    
    public struct SystemLabel: ReAttributedStringTrait {
        public let string       : String
        public let weight       : UIFont.Weight
        
        public let foreground   : UIColor
        
        public var representation: NSAttributedString {
            .init(string: string, attributes: [ .font : UIFont.systemFont(ofSize: 16, weight: weight) ])
        }
        
        public init(string: String, weight: UIFont.Weight = .regular, foreground: UIColor = Common.color.textbody.uicolor) {
            self.string     = string
            self.weight     = weight
            self.foreground = foreground
        }
    }
    
    public struct LinkText: ReAttributedStringTrait {
        
        public var string: String?
        public var substring: String?
        public var url: String?
        public var attribute: ReTextType?
        
        public init( string: String?, substring: String?, url: String?, attribute: ReTextType?) {
            self.string = string
            self.substring = substring
            self.url = url
            self.attribute = attribute
        }
        
        public var representation: NSAttributedString {
            
            guard let text = self.string else {
                return NSAttributedString(string: "")
            }
            
            guard let attribute = self.attribute else {
                return NSAttributedString()
            }
            
            // Create NSAttributedString first with attributes applied
            let font = UIFont.systemFont(
                ofSize: attribute.size,
                weight: attribute.fontWeight
            ).italize(attribute.isItalic)
            let attributedText = NSAttributedString(string: text, attributes: [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: attribute.color.uicolor
            ])
            
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedText.addAttributes([
                NSAttributedString.Key.link: NSURL(string: self.url ?? "")!,
                NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
                NSAttributedString.Key.underlineStyle: (NSUnderlineStyle.single.rawValue)
            ], range: NSString(string: text).range(of: self.substring ?? ""))

            return mutableAttributedText
        }
        
    }
    
    
    public struct IconText: ReAttributedStringTrait {

        public let icon         : Icon
        public let iconSize     : CGFloat
        public let foreground   : UIColor
        
        public var representation: NSAttributedString {
            let iconSize : CGFloat  = iconSize
            let iconFont : UIFont   = UIFont.icon(from: Fonts.SeriousMD, ofSize: iconSize)
            return NSAttributedString.init(
                string: icon.rawValue,
                attributes: [
                    NSAttributedString.Key.font             : iconFont,
                    NSAttributedString.Key.foregroundColor  : foreground
                ])
        }
        
        public init(icon: Icon, iconSize: CGFloat = 16, foreground: UIColor = Common.color.textbody.uicolor) {
            self.icon           = icon
            self.iconSize       = iconSize
            self.foreground     = foreground
        }
    }
    
    public struct Image: ReAttributedStringTrait {
        
        public let image    : UIImage
        public var width    : CGFloat? = nil
        public var height   : CGFloat? = nil
        public var position : CGPoint? = nil
        
        public var representation: NSAttributedString {
            .init(attachment: tell(NSTextAttachment()) {
                $0.image    = image
                
                $0.bounds   = .init(origin  : self.position ?? .init(x: 0, y: -2),
                                    size    : .init(
                                        width   : width     ?? (image.size.width / (image.size.height / 18)),
                                        height  : height    ?? 18)
                                    )
            })
        }
        
        public init(image: UIImage, width: CGFloat? = nil, height: CGFloat? = nil, position: CGPoint? = nil) {
            self.image      = image
            self.width      = width
            self.height     = height
            self.position   = position
        }
    }
}

extension Common {
    
    public static func textBuild(@ReTextBuilder _ contents: () -> NSAttributedString) -> NSAttributedString {
        contents()
    }
    
}
