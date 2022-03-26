//
//  CommonErrorWrapper.swift
//  SMDModuleUtility
//
//  Created by Gabriel Mori Baleta on 7/16/21.
//  Copyright © 2021 Leapfroggr Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit



/**
 * Commonview wrapper with added label and errors shown
 * - similar to SULResponsiveEntryNode
 */
open class ReEntry<T> : ResizeableNode, ErrorDisplayType where T : ASDisplayNode {
    
    public var label        : ReTextNode?
    public let display      : T!
    public var errorLabels  = [ASTextNode]()
    
    public required init(display: T) {
        self.display = display
        super.init()
    }
 
    public convenience init(label: String? = nil, required: Bool = false, display: T) {
        self.init(display: display)
        
        if let label = label {
            tell(ReTextNode()) {
                $0.attributedText = Common.attributedString(label, attribute: .sublabel).makeRequired(isRequired: required)
                self.label = $0
            }
        }
    }
    
    
    /// turns border red and displays errors passed
    /// - parameter errors: list of error messages.
    open func displayErrorMessage(_ errors: [String]) {
        if errors.isEmpty {
            clearErrorMessage()
            return
        }
        
        self.errorLabels = errors.map {ReTextNode($0, attribute: .warningLabel)}
        self.setNeedsLayout()
    }
    
    /// returns border back to normal and removes error labels
    open func clearErrorMessage() {
        self.errorLabels.removeAll()
        self.setNeedsLayout()
    }
    
    func displayChildren() -> [ASLayoutElement] {
        var children = [
            tell(self.display ?? ASDisplayNode()) {
                $0.style.flexGrow   = 1
                $0.style.flexShrink = 1
            },
        ] + self.errorLabels
        
        if let label = label {
            children.insert(label, at: 0)
        }
        return children
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASLayoutSpec
            .vStackSpec {
                self.displayChildren()
            }
            .spacing(5)
            .align()
    }
    
}//CommonEntryWrapper
