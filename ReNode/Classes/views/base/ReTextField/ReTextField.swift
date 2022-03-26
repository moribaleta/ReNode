//
//  ReTextField.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/17/22.
//

import Foundation
import AsyncDisplayKit
import UIKit
import RxSwift



/**
    extends from CommonTextview
        implements text aware on emiting text and clearing error messages
 */
open class ReTextField : ReTextFieldBase {
    
    public enum Restriction {
        case numberOnly
        case noReturn
        case tabEnter
    }
    
    public var restrictions : [Restriction] = []
    public var setValue     : String?
    
    public override var attributedText: NSAttributedString? {
        get {
            return self.textView.attributedText
        } set {
            self.setValue                   = newValue?.string
            self.textView.attributedText    = newValue
            self.onSetText(text: newValue?.string)
        }
    }
    
    public var placeholderNode = ASTextNode()
    
    open func onSetText(text: String?) {
        if text?.trim().isEmpty ?? true {
            self.placeholderNode.layer.opacity = 1
        } else {
            self.placeholderNode.layer.opacity = 0
        }
    }

    
    ///removes the text of the field
    public func clearText(){
        self.attributedText = Common.attributedString("")
    }
    
    public var placeholder : String? {
        didSet {
            self.placeholderNode.attributedText = Common.attributedString(self.placeholder ?? "", attribute: .placeholder, color: Common.baseColor.mediumgray.uicolor)
        }
    }
    
    ///returns the string from the textfield - auto clears error message thrown
    open var rxText : Observable<String?> {
        return self.emitText.asObservable()
    }
    
    open var rxDidBeginEditing : Observable<ReTextField> {
        return emitDidBeginEditing.asObservable()
    }
    
    open var rxDidEndEditing : Observable<ReTextField> {
        return emitDidEndEditing.asObservable()
    }
    
    open var rxOnReturnEnd : Observable<ReTextField> {
        return emitOnReturnEnd.asObservable()
    }
    
    open var rxOnTab : Observable<ReTextField> {
        return emitOnTab.asObservable()
    }
    
    var isInputNumber : Bool = false
    
    let emitText = PublishSubject<String?>()
    let emitDidBeginEditing = PublishSubject<ReTextField>()
    let emitDidEndEditing   = PublishSubject<ReTextField>()
    let emitOnReturnEnd     = PublishSubject<ReTextField>()
    let emitOnTab           = PublishSubject<ReTextField>()
    
    public override init() {
        super.init()
        self.field.placeholderEnabled           = false
        self.placeholderNode.textContainerInset = .init(all: 5).rightInset(30)
        //.init(top: 5, left: 5, bottom: 5, right: 30)
    }
    
    public convenience init(type: ReTextFieldType = .grey, placeholder: String = "", restrictions: [Restriction] = []) {
        self.init()
        self.type                           = type
        self.placeholderNode.attributedText = Common.attributedString(
                                                placeholder,
                                                attribute   : .placeholder,
                                                color       : Common.baseColor.mediumgray.uicolor)
        self.restrictions                   = restrictions
    }
    
    open override func didLoad() {
        super.didLoad()
        
        self.textView.delegate = self
        self.textView.rx.text
            .skip(1)
            .filter({ [unowned self] in self.setValue == nil || $0 != self.setValue})
            .subscribe(onNext: {
            [weak self] text in
            
            guard let this = self else {return}
                
            this.setValue = nil
                
            this.emitText.onNext(text)
                    
            if this.errorLabels.count > 0 {
                this.isMiddleEditing = true
                this.clearErrorMessage()
            }
        }).disposed(by: self.disposeBag)
        
        let tapper = UITapGestureRecognizer(
            target: self,
            action: #selector(onTapPlaceholder))
        self.placeholderNode.view.addGestureRecognizer(tapper)
    }//didLoad
    
    
    @objc func onTapPlaceholder(sender: Any?) {
        self.style(
            type            : self.type,
            hasError        : !self.errorLabels.isEmpty,
            isMiddleEditing : true)
        self.textView.becomeFirstResponder()
    }
    
    open override func style(type: ReTextFieldType, hasError: Bool, isMiddleEditing: Bool) {
        super.style(
            type            : type,
            hasError        : hasError,
            isMiddleEditing : isMiddleEditing)
        
        self.placeholderNode.layer.opacity = self.isMiddleEditing || !(textView.text.string.trim().isEmpty) ? 0 : 1
    }
    
    open func setValue(_ value: String) {
        self.attributedText = Common.attributedString(value)
    }
    
    ///func for adding text to value and determine if should emit change
    open func setText(text: String, emitChange: Bool = false) {
        self.setValue(text)
        if emitChange {
            self.emitLastChange()
        }
    }
    
    ///returns the text field value
    open func getValue() -> String? {
        return self.textView.text
    }
    
    ///calls emitText onNext to emit last value
    public func emitLastChange() {
        self.emitText.onNext(self.textView.text)
    }
    
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASLayoutSpec
            .vStackSpec {
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
            .spacing(8)
            .align()
        
        /*field.style.minHeight   = .init(unit: .points, value: 30)
        field.style.flexGrow    = 1
        field.style.flexShrink  = 1
        
        placeholderNode.style.minHeight     = .init(unit: .points, value: 30)
        placeholderNode.style.flexGrow      = 1
        placeholderNode.style.flexShrink    = 1
        
        let fieldOverview = ASOverlayLayoutSpec(child: field, overlay: placeholderNode)
        
        fieldOverview.style.flexGrow    = 1
        fieldOverview.style.flexShrink  = 1
        
        return ASStackLayoutSpec(direction: .vertical, spacing: 8,
                                justifyContent: .start, alignItems: .stretch,
                                children: [ fieldOverview ] + errorLabels)*/
    }//layoutSpecThatFits

}//ReTextField

extension ReTextField : UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if restrictions.contains(.numberOnly) {
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = text.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return text == numberFiltered
        }
        
        if restrictions.contains(.noReturn) {
            if text == "\n" {
                textView.resignFirstResponder()
                self.emitOnReturnEnd.onNext(self)
                return false
            }
        }
        
        if restrictions.contains(.tabEnter) {
            if text == "\t" {
                textView.resignFirstResponder()
                self.emitOnTab.onNext(self)
                return false
            }
        }
        
        return true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        self.isMiddleEditing = true
        self.style(type: self.type, hasError: !self.errorLabels.isEmpty, isMiddleEditing: true)
        self.emitDidBeginEditing.onNext(self)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        self.isMiddleEditing = false
        self.style(type: self.type, hasError: !self.errorLabels.isEmpty, isMiddleEditing: false)
        self.emitDidEndEditing.onNext(self)
    }
    
}//extension ReTextField : UITextViewDelegate





