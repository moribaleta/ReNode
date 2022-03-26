//
//  ReOptionButton.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift


/**
    UI VIEW for displaying a button with a "..." to show actions
 */
open class ReOptionButton : ReOptionButtonBase<ReOptionActionType> {

    public override init() {
        super.init()
        self.renderEntryCell = ReOptionButtonEntry.CREATE
    }
    
    public convenience init(options: [ReOptionActionType]) {
        self.init()
        self.options = options
    }

    
}//SULOptionButtonNode
