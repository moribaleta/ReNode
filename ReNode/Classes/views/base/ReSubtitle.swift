//
//  ReSubtitle.swift
//  ReNode
//
//  Created by Mini on 3/1/22.
//

import Foundation
import AsyncDisplayKit

/**
 displaynode, that looks like:
 ```
 label | label | label | ...
 ```
 */
open class ReSubtitle : ResizeableNode {
    public var labels = [ASTextNode]()
    public var separators = [ASDisplayNode]()
    
    public var borderLineColor : UIColor = Common.color.border_dashed.uicolor
    
    open func set(strings: [String], attribute: ReTextType = .sublabel, borderColor: UIColor = Common.color.border_line.uicolor) {
        labels.removeAll()
        labels = strings.map { string -> ASTextNode in
            return ReTextNode(string, attribute: attribute)
        }
        
        self.borderLineColor = borderColor
        
        let targetSeparatorCount = max(0, strings.count - 1)
        separators = (0..<targetSeparatorCount).map { i -> ASDisplayNode in
            let node = ASDisplayNode()
            node.backgroundColor = self.borderLineColor
            node.style.width = .init(unit: .points, value: 1)
            node.style.flexGrow = 1
            return node
        }
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var children = [ASDisplayNode]()
        for (i, label) in labels.enumerated() {
            if i > 0 {
                children.append(separators[i - 1])
            }
            children.append(label)
        }
        
        return ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .stretch, children: children)
    }
}
