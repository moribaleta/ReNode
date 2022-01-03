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
        ReAttributedStringTraits.CommonText(expression)
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
    
    public struct CommonText : ReAttributedStringTrait {
        
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
