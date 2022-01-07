//
//  SampleTexts.swift
//  ReNodeSample
//
//  Created by Mini on 1/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ReNode
import AsyncDisplayKit


class VCSampleTexts : ASDKViewController<SampleTexts> {
    static func spawn() -> VCSampleTexts {
        return tell( VCSampleTexts.init(node: .init()) ) {
            $0.title = "Texts"
        }
    }
}

class SampleTexts : ASDisplayNode {
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return ASStackLayoutSpec.vStackSpec {
            
            ReTextNode("Display \(ReTextType.displayText.size)", attribute: .displayText)
            
            ReTextNode("title \(ReTextType.title.size)", attribute: .title)
            
            ReTextNode("subtitle \(ReTextType.subtitle.size)", attribute: .subtitle)
            
            ReTextNode("titleText \(ReTextType.titleText.size)", attribute: .titleText)
            
            ReTextNode("templateButton \(ReTextType.templateButton.size)", attribute: .templateButton)

            ReTextNode("warningTitle \(ReTextType.warningTitle.size)", attribute: .warningTitle)

            ReTextNode("warningText \(ReTextType.warningText.size)", attribute: .warningText)

            ReTextNode("bodyText \(ReTextType.bodyText.size)", attribute: .bodyText)

            ReTextNode("disabledButton \(ReTextType.disabledButton.size)", attribute: .disabledButton)

            ReTextNode("disabledText \(ReTextType.disabledText.size)", attribute: .disabledText)

            ReTextNode("pillText \(ReTextType.pillText.size)", attribute: .pillText)

            ReTextNode("links \(ReTextType.links.size)", attribute: .links)

            ReTextNode("label \(ReTextType.label.size)", attribute: .label)

            ReTextNode("sublabel \(ReTextType.sublabel.size)", attribute: .sublabel)

            ReTextNode("warningLabel \(ReTextType.warningLabel.size)", attribute: .warningLabel)

            ReTextNode("titleLabel \(ReTextType.titleLabel.size)", attribute: .titleLabel)

            ReTextNode("placeholder \(ReTextType.placeholder.size)", attribute: .placeholder)
            
            
        }
        .insetSpec(self.safeAreaInsets)
        .insetSpec(.init(horizontal: 20, vertical: 10))
    }
    
    override func safeAreaInsetsDidChange() {
        setNeedsLayout()
    }
}
