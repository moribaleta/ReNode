//
//  ReTextFieldBase.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/17/22.
//

import Foundation
import AsyncDisplayKit
import UIKit
import RxSwift


/**
 * text field implements on is editing state
 * should not be extended from
 */
open class ReTextFieldBase : ResizeableNode {
    
    public var type : ReTextFieldType! = .grey {
        didSet {
            DispatchQueue.main.async {
                self.style(
                    type            : self.type,
                    hasError        : false,
                    isMiddleEditing : false)
            }}}
    
    public static let BORDER_RADIUS : CGFloat   = 6
    
    public var field                            = ASEditableTextNode()
    
    public var errorLabels                      = [ASTextNode]()
    
    public var disposeBag                       = DisposeBag()
    
    public var isMiddleEditing                  = false
    
    public lazy var textView    : UITextView    = { field.textView }()
    
    public var rxOnActive       : Observable<(ASDisplayNode, Bool)> {
        return emitOnActive.asObservable()
    }
    
    public var emitOnActive     = PublishSubject<(ASDisplayNode, Bool)>()
    
    public var attributedText   : NSAttributedString? {
        get {
            return field.attributedText
        }
        set {
            self.field.attributedText = newValue
        }
    }
    
    public var prevIsEditing : Bool = false {
        didSet{
            if prevIsEditing != oldValue {
                //need to get the latest height with keyboard added
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.emitOnActive.onNext((self, self.prevIsEditing))
                }
            }
        }
    }//prevIsEditing
    
    public override init() {
        super.init()
        self.backgroundColor        = UIColor.clear
        self.field.cornerRadius     = ReTextFieldBase.BORDER_RADIUS
        self.field.clipsToBounds    = true
    }
    
    public convenience init(type: ReTextFieldType) {
        self.init()
        self.type = type
    }
    
    open override func didLoad() {
        super.didLoad()
        
        tell(self.textView) {
            $0.font                  = UIFont.systemFont(ofSize: 15) //SULCommon.fontDefault(with: 15)
            $0.textColor             = type.isDisable ?
            Common.color.disabled_text_default.uicolor :
            Common.color.textbody.uicolor
            $0.textContainerInset    = .init(top: 5, left: 5, bottom: 5, right: 30)
            
            $0.rx.didBeginEditing
                .subscribe(onNext: {
                    [weak self] begin in
                    guard let this          = self else {return}
                    this.isMiddleEditing    = true
                    this.style(
                        type            : this.type,
                        hasError        : !this.errorLabels.isEmpty,
                        isMiddleEditing : true)
                })
                .disposed(by: disposeBag)
            
            $0.rx.didEndEditing
                .subscribe(onNext: {
                    [weak self] end in
                    guard let this          = self else {return}
                    this.isMiddleEditing    = false
                    this.style(
                        type            : this.type,
                        hasError        : !this.errorLabels.isEmpty,
                        isMiddleEditing : false)
                })
                .disposed(by: disposeBag)
            
        }//tell(self.textView)
        
        
        self.style(
            type            : self.type,
            hasError        : false,
            isMiddleEditing : self.isMiddleEditing)
    }//didLoad
    
    /// turns border red and displays errors passed
    /// - parameter errors: list of error messages.
    open func display(errors: [DisplayableError]) {
        displayErrorMessage(errors.map({ $0.description }))
    }//display
    
    /// turns border red and displays errors passed
    /// - parameter errors: list of error messages.
    open func displayErrorMessage(_ errors: [String]) {
        
        if errors.isEmpty {
            clearErrorMessage()
            return
        }
        
        self.errorLabels = errors.map { error in
            tell(ASTextNode()) {
                $0.attributedText = Common.attributedString(
                    error, attribute: .warningLabel)
            }
        }
        
        self.style(
            type            : self.type,
            hasError        : true,
            isMiddleEditing : self.isMiddleEditing)
        self.setNeedsLayout()
    }//displayErrorMessage
    
    /// returns border back to normal and removes error labels
    open func clearErrorMessage() {
        self.errorLabels = []
        self.style(
            type            : self.type,
            hasError        : false,
            isMiddleEditing : self.isMiddleEditing)
        self.setNeedsLayout()
    }//clearErrorMessage
    
    open func style(type: ReTextFieldType, hasError: Bool, isMiddleEditing: Bool) {
        
        self.isUserInteractionEnabled   = !type.isDisable
        
        if self.isMiddleEditing {
            self.field.backgroundColor  = type.activeBackgroundColor
            self.field.borderColor      = type.activeBorderColorFocus.cgColor
            self.field.borderWidth      = type.activeBorderWidth
        } else {
            self.field.backgroundColor  = type.normalBackgroundColor
            self.field.borderColor      = type.normalBorderColorFocus.cgColor
            self.field.borderWidth      = type.normalBorderWidth
        }
        
        if hasError {
            self.field.borderWidth  = type.warningBorderWidth
            self.field.borderColor  = type.warningColor.cgColor
        }
        
        self.prevIsEditing = self.isMiddleEditing
    }//style
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASLayoutSpec
            .vStackSpec {
                self.field
                    .frame(minHeight: 30)
                    .flex()
                self.errorLabels
            }
            .align()
            .spacing(8)
    }//layoutSpecThatFits
    

}//ReTextFieldBase
