//
//  ReTextFieldSearch.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import AsyncDisplayKit

/*
 * CommonTextview with search icon and clear button
 * copied from SULSearchBar
 */
public final class ReTextFieldSearch : ReTextField {
    
    var icon         = ASTextNode()
    var clearButton  = ReButton()
    
    public override var placeholder: String? {
        didSet {
            self.placeholderNode.attributedText = Common
                .attributedString(
                    self.placeholder ?? "",
                    attribute: .placeholder,
                    color: Common.color.search_placeholder.uicolor)
        }
    }
    
    public var textContent : String {
        return self.textView.text ?? ""
    }
    
    public override init(){
        super.init()
        self.type                   = .grey
        self.clearButton.isHidden   = true
        self.placeholder            = "Search"
    }
    
    public override func didLoad() {
        super.didLoad()
        if self.restrictions.contains(.noReturn) == false {
            self.restrictions.append(.noReturn)
        }
        
        self.icon.attributedText    = NSAttributedString(asIcon: Icon.actionSearch)
        self.clearButton.set(config: .ICON_CLOSE)
        
        self.field.textContainerInset           = .init(top: 5, sides: 30, bottom: 5)
        self.placeholderNode.textContainerInset = .init(top: 6, sides: 30, bottom: 5)
        
        self.rxText.subscribe(onNext: {
            [unowned self] text in
            self.clearButton.isHidden = text?.trim().isEmpty ?? true && !self.field.isFirstResponder()
        }).disposed(by: self.disposeBag)
        
        self.clearButton.rxTap.subscribe(onNext: {
            [unowned self] in
            self.clearSearch()
        }).disposed(by: self.disposeBag)
    }
    
    public override func onSetText(text: String?) {
        super.onSetText(text: text)
        self.clearButton.isHidden = (text?.trim().isEmpty ?? true)
    }
    
    public func clearSearch(){
        self.field.attributedText = NSAttributedString(string: "")
        self.emitText.onNext("")
        self.field.resignFirstResponder()
        self.clearButton.isHidden = true
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        super.layoutSpecThatFits(constrainedSize)
            .overlaySpec {
                ASLayoutSpec
                    .hStackSpec {
                        self.icon
                        self.clearButton
                    }
                    .justify(.spaceBetween)
                    .align()
                    .spacing(0)
                    .insetSpec(
                        .init(horizontal: 10, vertical: 6)
                        .rightInset(5)
                    )
            }
    }

}//CommonSearchBarNode

