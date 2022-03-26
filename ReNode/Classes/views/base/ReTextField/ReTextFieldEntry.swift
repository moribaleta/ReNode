//
//  ReTextFieldEntry.swift
//  ReNodeSample
//
//  Created by Gabriel Mori Baleta on 3/17/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit
import RxSwift


/**
 * ui component implements ReTextField
 */
open class ReTextFieldEntry : ReTextField {
    
    public var labelNode    = ASTextNode()
    
    public convenience init(type: ReTextFieldType = .grey, placeholder: String = "", label: String? = nil, isRequired: Bool = false, restrictions: [Restriction] = []) {
        self.init()
        self.type                           = type
        self.restrictions                   = restrictions
        self.placeholderNode.attributedText = Common.attributedString(
                                                placeholder,
                                                attribute   : .placeholder,
                                                color       : Common.baseColor.mediumgray.uicolor)
        self.labelNode.attributedText       = Common.attributedString(
                                                label ?? "",
                                                attribute   : .sublabel)
                                                .makeRequired(isRequired: isRequired)
    }
    
    
    public func setLabel(text: String, isRequired: Bool = false) {
        self.labelNode.attributedText = Common.attributedString(
                text , attribute: .sublabel)
            .makeRequired(isRequired: isRequired)
    }
    
    
    open func layoutFields() -> ASLayoutSpec {
        ASLayoutSpec
            .vStackSpec {
                self.labelNode
                
                ASWrapperLayoutSpec {
                    self.field
                }
                .flex(grow: 1, shrink: 1)
                .frame(minHeight: 30)
                .overlaySpec {
                    ASWrapperLayoutSpec {
                        self.placeholderNode
                    }
                    .flex(grow: 1, shrink: 1)
                    .frame(minHeight: 30)
                }
                .flex(grow: 1, shrink: 1)
                
                self.errorLabels
            }
            .spacing(5)
            .align()
    }//layoutFields
    
    
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASLayoutSpec
            .vStackSpec {
                self.layoutFields()
                self.errorLabels
            }
            .spacing(8)
            .align()
    }//layoutSpecThatFits
    

}//ReTextFieldEntry
