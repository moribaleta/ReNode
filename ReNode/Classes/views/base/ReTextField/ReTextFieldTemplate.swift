//
//  ReTextFieldTemplate.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/17/22.
//

import Foundation


public protocol ReTextFieldTemplate {
    
    var activeBackgroundColor   : UIColor{get}
    var activeBorderColorFocus  : UIColor{get}
    var activeBorderWidth       : CGFloat{get}
    
    var normalBackgroundColor   : UIColor{get}
    var normalBorderColorFocus  : UIColor{get}
    var normalBorderWidth       : CGFloat{get}
    
    var warningColor            : UIColor{get}
    var warningBorderWidth      : CGFloat{get}
    
}
