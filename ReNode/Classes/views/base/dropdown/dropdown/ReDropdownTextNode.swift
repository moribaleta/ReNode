//
//  ReDropdownTextNode.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/15/22.
//

import Foundation
import AsyncDisplayKit


/**
 * ui component inherits from ReDropdownNode
 * - displays entry into a text node
 */
open class ReDropdownTextNode<T> : ReDropdownNode<T> where T : ReDropdownEntryType {
    
    public override init() {
        super.init()
        
        self.renderDisplay = {
            val -> ASDisplayNode in
            tell(ReTextNode(val?.string ?? "")) {
                $0.textContainerInset = .topInset(5)
            }
        }
        
        self.renderEntryCell = {
            val -> ASCellNode in
            tell(ASTextCellNode()) {
                $0.textNode.attributedText = Common.attributedString(val.string)
            }
        }
    }
    
}//ReDropdownTextNode
