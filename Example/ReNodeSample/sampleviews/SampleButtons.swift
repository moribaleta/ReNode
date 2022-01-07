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


class VCSampleButtons : ASDKViewController<SampleButtons> {
    static func spawn() -> VCSampleButtons {
        return tell( VCSampleButtons.init(node: .init()) ) {
            $0.title = "Buttons"
        }
    }
}

class SampleButtons : ASDisplayNode {
    
    var button_link = ReButton()
    
    var button_dark = ReButton()
    var button_green = ReButton()
    var button_violet = ReButton()
    
    var button_light = ReButton()
    
    var button_blue = ReButton()
    
    
    var icon30_clear = ReButton()
    var icon30_gray = ReButton()
    var icon36_gray = ReButton()
    var icon36_black = ReButton()
    
    
    var icontext = ReButton()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
        
        button_link     .set(icon: "", text: "Link"     , config: .LINK     )
        
        button_dark     .set(icon: "", text: "DARK"     , config: .DARK     )
        button_green    .set(icon: "", text: "GREEN"    , config: .GREEN    )
        button_violet   .set(icon: "", text: "VIOLET"   , config: .VIOLET   )
        
        button_light    .set(icon: "", text: "LIGHT"    , config: .LIGHT    )
        
        button_blue     .set(icon: "", text: "Round Blue", config: .ROUND_BLUE)
        
        icon30_clear    .set(icon: Icon.actionAdd.rawValue, text: "", config: .ICON30_CLEAR)
        icon30_gray     .set(icon: Icon.actionAdd.rawValue, text: "", config: .ICON30_GRAY)
        icon36_gray     .set(icon: Icon.actionAdd.rawValue, text: "", config: .ICON36_GRAY)
        icon36_black    .set(icon: Icon.actionAdd.rawValue, text: "", config: .ICON36_BLACK)
        
        icontext        .set(icon: Icon.actionAdd.rawValue, text: "ADD", config: .DARK)
        
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
            icon30_clear
            icon30_gray
            icon36_gray
            icon36_black
            icontext
        }
        .insetSpec(self.safeAreaInsets)
        .insetSpec(.init(horizontal: 20, vertical: 10))
    }
    
    override func safeAreaInsetsDidChange() {
        setNeedsLayout()
    }
}
