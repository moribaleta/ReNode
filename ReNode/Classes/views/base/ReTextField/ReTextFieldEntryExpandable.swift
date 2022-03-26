//
//  ReTextFieldEntryExpandable.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/17/22.
//

import Foundation
import AsyncDisplayKit
import UIKit
import RxSwift


///common textfield that adapts to the current content size
open class ReTextFieldEntryExpandable : ReTextField {
    
    public var labelNode    = ASTextNode()
    
    public var minHeight    : CGFloat = 30
    public var maxHeight    : CGFloat = 250
    
    public convenience init(type: ReTextFieldType = .grey, placeholder: String = "", label: String? = nil, isRequired: Bool = false) {
        self.init()
        self.type                           = type
        self.placeholderNode.attributedText = Common.attributedString(
                                                placeholder,
                                                attribute   : .placeholder,
                                                color       : Common.baseColor.mediumgray.uicolor)
        self.labelNode.attributedText       = Common.attributedString(
                                                label ?? "",
                                                attribute: .sublabel)
                                                .makeRequired(isRequired: isRequired)
    }
    
    open override func didLoad() {
        super.didLoad()
        
        self.rxText.throttle(.milliseconds(200),
                             scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged({ $0?.lastIndex(of: "\n") == $1?.lastIndex(of: "\n") })
            .subscribe(onNext: {
            [unowned self] _ in
            self.supernode?.setNeedsLayout()
        }).disposed(by: self.disposeBag)
    }
    
    open override func setText(text: String, emitChange: Bool = false) {
        super.setText(text: text, emitChange: emitChange)
        self.supernode?.setNeedsLayout()
    }
    
    open func computeHeight(width: CGFloat) -> CGFloat {
        var count           = self.textView.attributedText.string.count
        let nlines          = CGFloat(self.textView.attributedText.string.numberOfLines)
        count               = count <= 0 ? 1 : count
        let maxcount_line   = (width - 20)/5.2
        var height          = (CGFloat(count) / maxcount_line) * self.minHeight
        height              = height <= self.minHeight ? self.minHeight : height
        height              = nlines > 1 ? ((nlines * self.minHeight) + height) : height
        return height + 3
    }//computeHeight
    
    
    open func layoutField(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        make(
            ASLayoutSpec.vStackSpec {
            if (labelNode.attributedText?.string.count ?? 0) > 0 {
                self.labelNode
            }
            
            self.field.frame(
                minHeight: self.minHeight,
                maxHeight: self.maxHeight
            )
            .fraction(width: 1)
            .overlaySpec {
                self.placeholderNode.frame(
                    minHeight: self.minHeight
                )
                .flex(grow: 1, shrink: 1)
            }
            .flex(grow: 1, shrink: 1)
        }
        .spacing(5)
        .align()) {
            if self.field.frame.height < self.maxHeight || self.type.isDisable {
                self.field
                    .frame(
                        height: computeHeight(width: constrainedSize.max.width)
                    )
            }
        }
    }//layoutField
    
    
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASLayoutSpec
            .vStackSpec {
                self.layoutField(constrainedSize)
                errorLabels
            }
            .align()
            .spacing(8)
    }//layoutSpecThatFits
    

}//ReTextFieldEntryExpandable

