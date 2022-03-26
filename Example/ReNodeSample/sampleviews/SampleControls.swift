//
//  SampleControls.swift
//  ReNodeSample
//
//  Created by Mini on 2/28/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ReNode
import AsyncDisplayKit

class VCSampleControls : ASDKViewController<SampleControls> {
    static func spawn() -> VCSampleControls {
        return tell( VCSampleControls.init(node: .init()) ) {
            $0.title = "Controls"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

class SampleControls : ASDisplayNode {
    
    var check = ReCheckbox()
    var radio = ReRadio()
    
    var checklabel = ReCheckbox()
    var radioLabel = ReRadio()
    
    
    var radioGroup = ReRadioGroup(values: (0...5).map({ $0.description }) )
    var scrollNode  : ReScrollNode!
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
        
        self.scrollNode = tell(.init()) {
            $0?.layoutSpecBlock = {
                [unowned self] _,_ in
                self.layoutContent()
            }
        }
        
        self.checklabel.set(text: "ReCheckbox")
        
        self.radioLabel.object = "ReRadio"
        
        
        
    }
    
    
    func layoutContent() -> ASLayoutSpec {
        ASStackLayoutSpec.vStackSpec {
            self.check
            self.radio
            self.checklabel
            self.radioLabel
            
            self.radioGroup
        }
        .align()
        .insetSpec(self.safeAreaInsets)
        .insetSpec(.init(horizontal: 20, vertical: 10))
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec {
            self.scrollNode
        }
    }
    
    override func safeAreaInsetsDidChange() {
        setNeedsLayout()
    }
}
