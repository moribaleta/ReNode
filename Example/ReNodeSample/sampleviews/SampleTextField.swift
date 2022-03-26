//
//  SampleTextField.swift
//  ReNodeSample
//
//  Created by Gabriel Mori Baleta on 3/17/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReNode
import RxCocoa
import RxSwift

class VCSampleTextField : ASDKViewController<UISampleTextField> {
    
    static func spawn() -> VCSampleTextField {
        return VCSampleTextField(node: .init())
    }
    
    override func loadView() {
        super.loadView()
        self.title = "Sample TextFields"
    }
}

class UISampleTextField : ReScrollNode {
    
    override init() {
        super.init()
        
        self.backgroundColor = .white
        
        let textFieldWhite      = ReTextField(type: .white, placeholder: "white")
        let textFieldGrey       = ReTextField(type: .grey, placeholder: "grey")
        let textFieldClear      = ReTextField(type: .clear, placeholder: "clear")
        let textFieldDisable    = ReTextField(type: .disable, placeholder: "disable")
        let textFieldPreview    = ReTextField(type: .preview, placeholder: "preview")
        let textFieldCustom     = ReTextField(
            type: .custom(
                activeBackgroundColor   : .blue,
                activeBorderColorFocus  : .green,
                activeBorderWidth       : 1,
                normalBackgroundColor   : .green,
                normalBorderColorFocus  : .blue,
                normalBorderWidth       : 1,
                warningColor            : .red,
                warningBorderWidth      : 1),
            placeholder                 : "CUSTOM")
        
        let searchField     = ReTextFieldSearch(
            type: .grey
        )
        
        
        let entryField = ReTextFieldEntry(
            type        : .grey,
            placeholder : "Entry Value",
            label       : "Entry Field")
        
        let expandableField = ReTextFieldEntryExpandable(
            type: .grey, placeholder: "Expandable", label: "Expandable Field"
        )
        
        self.layoutSpecBlock = {
            _,_ in
            ASLayoutSpec
                .vStackSpec {
                    
                    ASLayoutSpec
                        .vStackSpec {
                            textFieldWhite
                            textFieldGrey
                            textFieldClear
                            textFieldDisable
                            textFieldPreview
                            textFieldCustom
                        }.align()
                    
                    searchField
                    
                    entryField
                    
                    expandableField
                }
                .spacing(20)
                .align()
                .insetSpec(
                    .init(horizontal: 10, vertical: 10)
                    .topInset(UIScreen.main.safeAreaInsetZero().top))
        }
    }
    
}
