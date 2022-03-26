//
//  ReOptionButtonCustomNode.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import AsyncDisplayKit

/**
 UI VIEW for displaying a button with a "..." to show actions
 */
open class ReOptionButtonCustom : ReOptionButtonBase<ReOptionActionItem> {
    
    public var selected        : ReOptionActionItem?
    
    public convenience init(options: [ReOptionActionItem]) {
        self.init()
        self.options = options
    }
    
    public override init() {
        super.init()
        
        self.emitSelection
            .rx
            .bind {
                [unowned self] selected in
                self.selected = selected
            }
            .disposed(by: self.disposeBag)
        
        self.renderEntryCell = {
            option -> ASCellNode in
            ReOptionButtonEntry(icon: option.icon, title: option.title)
        }
    }

    
}//SULOptionButtonNode
