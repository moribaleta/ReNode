//
//  ReBorder.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import AsyncDisplayKit

/**
    ui view for displaying border
 */
open class ReBorderNode : ASDisplayNode {
    
    public enum Direction {
        case vertical
        case horizontal
    }
    
    public var direction   : Direction = .horizontal {
        didSet {
            if self.direction == .horizontal {
                self.style.width     = .init(unit: .fraction, value: 1)
                self.style.height    = .init(unit: .points, value: self.lineWidth)
            }else{
                self.style.width     = .init(unit: .points, value: self.lineWidth)
                self.style.height    = .init(unit: .fraction, value: 1)
            }
            self.setNeedsLayout()
        }
    }
    
    public var lineWidth   : CGFloat = 1 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private override init() {
        super.init()
    }
    
    public init(direction: ReBorderNode.Direction = .horizontal, lineWidth: CGFloat = 1, backgroundColor: UIColor = Common.color.border_line.uicolor) {
        super.init()
        if direction == .horizontal {
            self.style.width     = .init(unit: .fraction, value: 1)
            self.style.height    = .init(unit: .points, value: lineWidth)
        }else{
            self.style.width     = .init(unit: .points, value: lineWidth)
            self.style.height    = .init(unit: .fraction, value: 1)
        }
        self.backgroundColor = backgroundColor
        self.direction       = direction
        self.lineWidth       = lineWidth
    }
    
    
    public init(direction: ReBorderNode.Direction = .horizontal, lineWidth: CGFloat = 1, colorType: CommonColorType = Common.color.border_line) {
        super.init()
        if direction == .horizontal {
            self.style.width     = .init(unit: .fraction, value: 1)
            self.style.height    = .init(unit: .points, value: lineWidth)
        }else{
            self.style.width     = .init(unit: .points, value: lineWidth)
            self.style.height    = .init(unit: .fraction, value: 1)
        }
        self.backgroundColor = colorType.uicolor
        self.direction       = direction
        self.lineWidth       = lineWidth
    }
    
}
