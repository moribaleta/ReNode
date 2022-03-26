//
//  UIEdgeInsets.swift
//  SMDModuleUtility
//
//  Created by Michael Ong on 8/8/17.
//  Copyright © 2017 Leapfroggr Inc. All rights reserved.
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

public extension UIEdgeInsets {
    
    /**
     * creates a zero inset with the added inset on top
     */
    static func topInset(_ inset: CGFloat) -> Self {
        .zero.topInset(inset)
    }
    
    /**
     * creates a zero inset with the added inset in the bottom
     */
    static func bottomInset(_ inset: CGFloat) -> Self {
        .zero.bottomInset(inset)
    }
    
    /**
     * creates a zero inset with the added inset on the left
     */
    static func leftInset(_ inset: CGFloat) -> Self {
        .zero.leftInset(inset)
    }
    
    /**
     * creates a zero inset with the added inset on the right
     */
    static func rightInset(_ inset: CGFloat) -> Self {
        .zero.rightInset(inset)
    }
    
    func topInset(_ inset: CGFloat) -> Self {
        var this = self
        this.top = inset
        return this
    }
    
    func bottomInset(_ inset: CGFloat) -> Self {
        var this = self
        this.bottom = inset
        return this
    }
    
    func leftInset(_ inset: CGFloat) -> Self {
        var this = self
        this.left = inset
        return this
    }
    
    func rightInset(_ inset: CGFloat) -> Self {
        var this = self
        this.right = inset
        return this
    }
    
}
