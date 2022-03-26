//
//  ReTextFieldType.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/17/22.
//

import Foundation

public enum ReTextFieldType  {
    
    case white
    case grey
    case clear
    case disable
    case preview
    case custom (
        activeBackgroundColor   : UIColor = ReTextFieldType.grey.activeBackgroundColor   ,
        activeBorderColorFocus  : UIColor = ReTextFieldType.grey.activeBorderColorFocus  ,
        activeBorderWidth       : CGFloat = ReTextFieldType.grey.activeBorderWidth       ,
        normalBackgroundColor   : UIColor = ReTextFieldType.grey.normalBackgroundColor   ,
        normalBorderColorFocus  : UIColor = ReTextFieldType.grey.normalBorderColorFocus  ,
        normalBorderWidth       : CGFloat = ReTextFieldType.grey.normalBorderWidth       ,
        warningColor            : UIColor = ReTextFieldType.grey.warningColor            ,
        warningBorderWidth      : CGFloat = ReTextFieldType.grey.warningBorderWidth      )
    
}

extension ReTextFieldType : ReTextFieldTemplate {
    
    public var type : String {
        switch self {
        case .grey:
            return "grey"
        case .disable:
            return "disable"
        case .white:
            return "white"
        case .preview:
            return "preview"
        case .clear:
            return "clear"
        case .custom(_,_, _, _, _, _, _, _):
            return "custom"
        }
    }
    
    public var isDisable : Bool {
        switch self {
        case .disable, .preview:
            return true
        default:
            return false
        }
    }
    
    public var activeBackgroundColor: UIColor {
        switch self {
        case .custom(let background, _, _, _, _, _, _, _):
            return background
        default:
            return UIColor.white
        }
    }
    
    public var activeBorderColorFocus: UIColor {
        switch self {
        case .grey:
            return .black
        case .disable:
            return Common.color.border_line_light.uicolor
        case .preview:
            return Common.color.border_line_light.uicolor
        case .white:
            return .black
        case .clear:
            return .black
        case .custom(_,let border_color, _, _, _, _, _, _):
            return border_color
        }
    }
    
    public var activeBorderWidth: CGFloat {
        switch self {
        case .grey:
            return 0.5
        case .disable, .preview:
            return 0.5
        case .white:
            return 0.5
        case .clear:
            return 0.5
        case .custom(_,_,let border, _, _, _, _, _):
            return border
        }
    }
    
    public var normalBackgroundColor: UIColor {
        switch self {
        case .grey:
            return Common.color.background_text.uicolor
        case .disable:
            return Common.color.border_line_light.uicolor
        case .preview:
            return .white
        case .white:
            return .white
        case .clear:
            return .clear
        case .custom(_,_,_,let color, _, _, _, _):
            return color
        }
    }
    
    public var normalBorderColorFocus: UIColor {
        
        switch self {
        case .grey:
            return Common.color.border_line.uicolor
        case .disable:
            return Common.color.border_line_light.uicolor
        case .preview:
            return Common.color.border_line.uicolor
        case .white:
            return Common.color.border_line.uicolor
        case .clear:
            return Common.color.border_line.uicolor
        case .custom(_,_,_,_,let color, _, _, _):
            return color
        }
    }
    
    public var normalBorderWidth: CGFloat {
        switch self {
        case .grey:
            return 0.5
        case .disable:
            return 0.5
        case .preview:
            return 0.5
        case .white:
            return 0.5
        case .clear:
            return 0
        case .custom(_,_,_,_,_, let border, _, _):
            return border
        }
    }
    
    public var warningColor: UIColor {
        switch self {
        case .custom(_,_,_,_,_, _, let color, _):
            return color
        default:
            return Common.color.warning.uicolor
        }
    }
    
    public var warningBorderWidth: CGFloat {
        switch self {
        case .custom(_,_,_,_,_, _, _, let border):
            return border
        default:
            return 0.5
        }
    }
    
}
