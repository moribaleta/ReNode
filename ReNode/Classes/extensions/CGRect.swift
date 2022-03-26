//
//  CGRect.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation
import Foundation
import CoreGraphics

public extension CGRect {

    var middle: CGPoint { return .init(x: midX, y: midY) }

    var bounds: CGRect  { return .init(origin: .zero, size: size) }
}

public extension CGSize {
    
    static func equal(_ size: CGFloat) -> CGSize {
        .init(width: size, height: size)
    }
    
    
}
