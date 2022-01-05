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
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        
        scroll.automaticallyManagesSubnodes = true
        scroll.automaticallyManagesContentSize = true
        
        scroll.layoutSpecBlock = { [unowned self] node, size -> ASLayoutSpec in
            
            ASStackLayoutSpec.vStackSpec {
                self.texts
                self.buttons
            }
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        backgroundColor = .white
        scroll.backgroundColor = .white
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec.init(insets: .zero, child: scroll)
    }
}
