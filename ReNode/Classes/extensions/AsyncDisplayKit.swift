//
//  AsyncDisplayKit.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation
import AsyncDisplayKit


public extension ASDisplayNode {
    
    func border(radius: CGFloat, noBorder: Bool = false, hairline: Bool = false, color: CGColor = Common.color.border_line.cgColor) {
        self.borderColor    = color
        self.borderWidth    = noBorder ? 0 : (hairline ? 1 / UIScreen.main.scale : 1)
        self.cornerRadius   = radius
    }
}


public struct DropShadow {
    public var offset   : CGSize    = CGSize(width: 0, height: 0)
    public var opacity  : Float     = 0.3
    public var radius   : CGFloat   = 10
    public var color    : CGColor   = UIColor.black.cgColor
}

public extension ASDisplayNode {

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
}
