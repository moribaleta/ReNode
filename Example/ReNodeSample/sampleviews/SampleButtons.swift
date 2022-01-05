//
//  SampleButtons.swift
//  ReNodeSample
//
//  Created by Mini on 1/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReNode

class SampleButtons : ASDisplayNode {
    
    var button_link = ReButton()
    
    var button_dark = ReButton()
    var button_green = ReButton()
    var button_violet = ReButton()
    
    var button_light = ReButton()
    
    var button_blue = ReButton()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        
        
        button_link     .set(icon: "", text: "Link"     , config: .LINK     )
        
        button_dark     .set(icon: "", text: "DARK"     , config: .DARK     )
        button_green    .set(icon: "", text: "GREEN"    , config: .GREEN    )
        button_violet   .set(icon: "", text: "VIOLET"   , config: .VIOLET   )
        
        button_light    .set(icon: "", text: "LIGHT"    , config: .LIGHT    )
        
        button_blue     .set(icon: "", text: "Round Blue", config: .ROUND_BLUE)
    }
    
    override func didLoad() {
        super.didLoad()
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return ASStackLayoutSpec.vStackSpec {
            button_link
            button_dark
            button_green
            button_violet
            button_light
            button_blue
        }
    }
}
