//
//  Common.swift
//  SMDModuleUtility
//
//  Created by Mini on 3/18/20.
//  Copyright © 2020 Leapfroggr Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

public class Common {
    
    ///cannot be reference for  different sizes of  ipad
    public static let ipad_width : CGFloat = 768
    
    ///corner - 8
    public static let div_corner_radius : CGFloat = 8
    
    ///cornder - 10
    public static let box_corner_radius : CGFloat = 10
    
    ///corner - 6
    public static let text_corner_radius : CGFloat = 6
    
    public enum color : CommonColorType {
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
        
        ///"#7B8185"
        //case border_line
        
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
        
        ///#00D57E
        case success_toast
        
        ///#FE4951
        case danger_toast
        
        case border_line_survey

        case new_patient
        
        public var uicolor : UIColor {
            return .hex(self.rawValue) //UIColor(hexString: self.rawValue)
        }
        
        public var cgColor : CGColor {
            return self.uicolor.cgColor
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
                //return "#7B8185"
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
            case .success_toast:
                return "#00D57E"
            case .danger_toast:
                return "#FE4951"
            
            case .border_line_survey:
                return "#7B8185"
            case .new_patient:
                return "#2d9bf0"
            }
        }
    }
    
    public enum baseColor : String, CommonColorType {
        /**
         ~~~
         UIColor(#212121)
         ~~~
         */
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
        //case lightviolet    = "#7E2DA0"
        ///"#736FDC"
        case lightviolet    = "#736FDC"
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
        
        case white          = "#FFFFFF"
        
        public var uicolor : UIColor {
            return .hex(self.rawValue)//UIColor(hexString: self.rawValue)
        }
        
        public var cgColor : CGColor {
            return self.uicolor.cgColor
        }
    }
    
    public enum fontSize : CGFloat {
        case title  = 18
        case text   = 15
        case labels = 12
    }
    
    public static let dropShadow = DropShadow()
}


///protocol used to define a color base
public protocol CommonColorType {
    
    var uicolor : UIColor {get}
    var cgColor : CGColor {get}
    
}
