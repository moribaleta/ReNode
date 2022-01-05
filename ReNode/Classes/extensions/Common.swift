//
//  Common.swift
//  ReactiveNodeSample
//
//  Created by Gabriel Mori Baleta on 8/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

public class Common {
    
    ///cannot be reference for  different sizes of  ipad
    public static let ipad_width : CGFloat = 768
    
    ///corner - 8
    public static let div_corner_radius : CGFloat = 8
    
    ///corner - 6
    public static let text_corner_radius : CGFloat = 6
    
    public enum color {
        ///"#212121"
        case header_title
        ///"#7D7D7D"
        case label
        ///"#212121"
        case textbody
        ///"#E1E1E1"
        case placeholder
        ///"#ECECEC"
        case background_text
        ///"#212121"
        case icon
        ///"#BCBCBC"
        case close_icon
        
        ///"#ECECEC"
        case background_icon_default
        ///"#E1E1E1"
        case background_icon_fill
        
        ///"#212121"
        case button_fill
        ///"#7D7D7D"
        case button_border_background
        ///"#BCBCBC"
        case checkbox_border
        ///"#212121"
        case checkbox_border_background
        
        ///"#7D7D7D"
        case disabled_text_default
        ///"#E1E1E1"
        case disabled_text_fill
        
        ///"#BCBCBC"
        case favorite_icon_empty
        ///"#00C088"
        case favorite_icon_fill
        
        ///"#E1E1E1"
        case border_dashed
        ///"#ECECEC"
        case border_line
        ///"#F5F5F5"
        case border_line_light
        
        ///"#7D7D7D"
        case pill_default_active
        ///"#FFFFFF"
        case pill_default_empty
        ///"#0090F5"
        case template_text
        
        ///"#FF4B54"
        case warning
        
        ///"#7D7D7D"
        case empty_text
        ///"#919191"
        case search_placeholder
        
        
        public var uicolor : UIColor {
            return UIColor.hex(rawValue)
        }
        
        public var rawValue : String {
            switch self {
            case .header_title:
                return "#212121"
            case .label:
                return "#7D7D7D"
            case .textbody:
                return "#212121"
            case .placeholder:
                return "#E1E1E1"
            case .background_text:
                return "#ECECEC"
            case .icon:
                return "#212121"
            case .close_icon:
                return "#BCBCBC"
                
            case .background_icon_default:
                return "#ECECEC"
            case .background_icon_fill:
                return "#E1E1E1"
            
            case .button_fill:
                return "#212121"
            case .button_border_background:
                return "#7D7D7D"
            case .checkbox_border:
                return "#BCBCBC"
            case .checkbox_border_background:
                return "#212121"
                
            case .disabled_text_default:
                return "#7D7D7D"
            case .disabled_text_fill:
                return "#E1E1E1"
                
            case .favorite_icon_empty:
                return "#BCBCBC"
            case .favorite_icon_fill:
                return "#00C088"
                
            case .border_dashed:
                return "#E1E1E1"
            case .border_line:
                return "#ECECEC"
            case .border_line_light:
                return "#F5F5F5"
            
            case .pill_default_active:
                return "#7D7D7D"
            case .pill_default_empty:
                return "#FFFFFF"
            case .template_text:
                return "#0090F5"
                
            case .warning:
                return "#FF4B54"
            
            case .empty_text:
                return "#7D7D7D"
            case .search_placeholder:
                return "#919191"
            }
        }
    }
    
    public enum baseColor : String {
        /**
         ~~~
         UIColor(#212121)
         ~~~
         */
        case white          = "#FFFFFF"
        
        case black          = "#212121"
        
        ///"#7D7D7D"
        case gray           = "#7D7D7D"
        
        ///"#ECECEC"
        case disabled       = "#ECECEC"
        
        ///"#0090F5"
        case blue           = "#0090F5"
        
        ///"#FF4B54"
        case red            = "#FF4B54"
        
        ///"#FFC53A"
        case yellow         = "#FFC53A"
        
        ///"#FF653A"
        case orange         = "#FF653A"
        
        ///"#4137AE"
        case violet         = "#4137AE"
        
        ///"#00C088"
        case green          = "#00C088"
        
        ///"#00D67F"
        case lightgreen     = "#00D67F"
        
        ///"#DB1259"
        case pink           = "#DB1259"
        
        ///"#7E2DA0"
        case lightviolet    = "#7E2DA0"
        
        ///"#00C3F9"
        case lightblue      = "#00C3F9"
        
        ///"#FF9C3A"
        case lightorange    = "#FF9C3A"
        
        ///"#95C72C"
        case mossgreen      = "#95C72C"
        
        ///"#00CAAF"
        case persiangreen   = "#00CAAF"
        
        ///"#E1E1E1"
        case lightgray      = "#E1E1E1"
        
        ///"#D3D3D3"
        case mediumgray     = "#D3D3D3"
        
        ///"#BCBCBC"
        case darkgray       = "#BCBCBC"
        
        ///"#62F8D1"
        case mint           = "#62F8D1"
        
        ///"#8EE9FF"
        case skyblue        = "#8EE9FF"
        
        ///"#AOC80B"
        case babyblue       = "#AOC80B"
        
        ///"#BDB1E4"
        case lavender       = "#BDB1E4"
        
        ///"#D8AFE2"
        case lilac          = "#D8AFE2"
        
        ///"#FFB5A7"
        case salmon         = "#FFB5A7"
        
        ///"#FFCE5E"
        case dandelion      = "#FFCE5E"
        
        ///"#FFED54"
        case lemon          = "#FFED54"
        
        ///"#A6FF64"
        case neonGreen      = "#A6FF64"
        
        ///"#74F393"
        case spring         = "#74F393"
        
        ///"#ABDF77"
        case pear           = "#ABDF77"
        
        public var uicolor : UIColor {
            return UIColor.hex(self.rawValue)
        }
        
        public var cgColor : CGColor {
            return self.uicolor.cgColor
        }
    }
    
    public enum fontSize : Int {
        case title  = 18
        case text   = 15
        case labels = 12
    }
    
    public static let dropShadow = DropShadow()
}

public struct DropShadow {
    public var offset   : CGSize    = CGSize(width: 0, height: 0)
    public var opacity  : Float     = 0.3
    public var radius   : CGFloat   = 10
    public var color    : CGColor   = UIColor.black.cgColor
}

public extension CALayer {
    
    @discardableResult func shadowOffset(_ offset: CGSize) -> Self {
        self.shadowOffset = offset
        return self
    }
    
    @discardableResult func shadowOpacity(_ opacity: Float) -> Self {
        self.shadowOpacity = opacity
        return self
    }
    
    @discardableResult func shadowRadius(_ radius: CGFloat) -> Self {
        self.shadowRadius = radius
        return self
    }
    
    @discardableResult func shadowColor(_ color: UIColor) -> Self {
        self.shadowColor = color.cgColor
        return self
    }
    
    @discardableResult func shadowColor(_ color: CGColor) -> Self {
        self.shadowColor = color
        return self
    }
}


public extension ASDisplayNode {
    
    @discardableResult func dropShadow(offset: CGSize? = nil,opacity: Float? = nil,radius: CGFloat? = nil,color: CGColor? = nil) -> CALayer {
        self.layer.shadowOffset     = Common.dropShadow.offset
        self.layer.shadowOpacity    = Common.dropShadow.opacity
        self.layer.shadowRadius     = Common.dropShadow.radius
        self.layer.shadowColor      = Common.dropShadow.color
        return self.layer
    }

    func dropShadowDefault() {
        self.layer.shadowOffset     = Common.dropShadow.offset
        self.layer.shadowOpacity    = Common.dropShadow.opacity
        self.layer.shadowRadius     = Common.dropShadow.radius
        self.layer.shadowColor      = Common.dropShadow.color
    }
    
    func dropShadowCreate(offset: CGSize? = nil,opacity: Float? = nil,radius: CGFloat? = nil,color: CGColor? = nil) {
        self.layer.shadowOffset     = offset ?? Common.dropShadow.offset
        self.layer.shadowOpacity    = opacity ?? Common.dropShadow.opacity
        self.layer.shadowRadius     = radius ?? Common.dropShadow.radius
        self.layer.shadowColor      = color ?? Common.dropShadow.color
    }
    
    func clearDropShadowDefault() {
        self.layer.shadowOffset     = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity    = 0
        self.layer.shadowRadius     = 0
        self.layer.shadowColor      = UIColor.clear.cgColor
    }
        
    
    func border(radius: CGFloat, hairline: Bool = false, color: UIColor = Common.color.border_line.uicolor) {
        self.borderColor    = color.cgColor
        self.borderWidth    = hairline ? 1 / UIScreen.main.scale : 1
        self.cornerRadius   = radius
    }

    
}


