//
//  UIEdgeInsets.swift
//  SampleApp
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//

import Foundation
import UIKit

extension UIEdgeInsets {

    public init(all value: CGFloat) {

        self.init(top: value, left: value, bottom: value, right: value)
    }

    public init(top t: CGFloat, sides s: CGFloat, bottom b: CGFloat) {

        self.init(top: t, left: s, bottom: b, right: s)
    }

    public init(horizontal h: CGFloat, vertical v: CGFloat) {

        self.init(top: v, left: h, bottom: v, right: h)
    }
}

public extension CGRect {

    public var middle: CGPoint { return .init(x: midX, y: midY) }

    public var bounds: CGRect  { return .init(origin: .zero, size: size) }
}

