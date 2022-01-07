//
//  SampleView.swift
//  ReNodeSample
//
//  Created by Mini on 1/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ReNode
import AsyncDisplayKit

class SampleView : ReactiveNode<SampleState> {
    
    var scroll = ASScrollNode()
    
    var texts = SampleTexts()
    var buttons = SampleButtons()
    
    var table = ReTable<String>()
    var list = ["Text", "Button", "Textfield", "Dropdown/Datedown", "Checkbox/Radio/SegmentControl", "Modal" ]
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        
        table.singleListBind(simple: .just(.init(list)))
        table.renderCell = { element, table, props -> ASCellNode in
            let cell = ASTextCellNode.init(attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)], insets: .init(horizontal: 16, vertical: 16))
            cell.text = element
            return cell
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec.init(insets: .zero, child: table)
    }
}
