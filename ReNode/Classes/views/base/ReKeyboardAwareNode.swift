//
//  ReKeyboardAwareNode.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/14/22.
//

import Foundation
import AsyncDisplayKit


/**
 * ReactiveNode with self awareness from keyboard height and shows dismiss keyboard button if device is mobile
 */
open class ReKeyboardAwareNode<T> : ReactiveNode<T> {
    
    ///contains the view of the container can be nullable if asdisplaynode is provided
    public var containerView    : UIView?
    
    ///contains the node of the container
    public var containerNode    : ASDisplayNode!
    
    ///dismiss button to dismiss keyboard
    public var dismissKey       : ReButton!
    
    ///height of the keyboard if shown
    public var keyboardHeight   : CGFloat = 0
    
    public override init() {
        super.init()
        self.containerNode      = ResizeableNode()
        self.dismissKey         = .DISMISS_KEY
    }
    
    open func setView(view: UIView){
        self.containerView = view
        self.containerNode = .init(viewBlock: {
            view
        })
        self.setNeedsLayout()
    }
    
    open func setNode(node: ASDisplayNode){
        self.containerNode = node
        self.setNeedsLayout()
    }
    
    open override func didLoad() {
        super.didLoad()
        
        let keyboardUtil = KeyboardUtilities.instance
        
        keyboardUtil
            .rxKeyboard
            .subscribe(onNext: {
            [weak self] keyboard in
            guard let this = self else { return }
            this.keyboardHeight = keyboard.isFloating ? 0 : keyboard.height
            this.setNeedsLayout()
        }).disposed(by: self.disposeBag)
        
        self.dismissKey.rxTap.subscribe(onNext: {
            [weak self] in
            UIApplication.shared.dismissKeyboard()
        }).disposed(by: self.disposeBag)
    }
    
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        /*self.containerNode.style.flexGrow     = 1
        self.containerNode.style.flexShrink   = 1
        
        let insetDismiss    = ASInsetLayoutSpec(insets: .init(all: 10), child: self.dismissKey)
        
        let relativeDismiss = ASRelativeLayoutSpec(horizontalPosition: .end, verticalPosition: .end,
                                                   sizingOption: .minimumWidth, child: insetDismiss)
        
        let overlay = ASOverlayLayoutSpec(
                            child: self.containerNode,
                            overlay: self.keyboardHeight > 50 && UIDevice.current.userInterfaceIdiom == .phone ?  relativeDismiss : ASLayoutSpec())
        
        overlay.style.flexGrow      = 1
        overlay.style.flexShrink    = 1
        
        let safearea = UIScreen.main.safeAreaInset(top: 0, sides: 0, bottom: self.keyboardHeight)
        
        return ASInsetLayoutSpec(insets: .init(top: 0, sides: 0, bottom: safearea.bottom), child: overlay)*/
        
        self.containerNode
            .flex()
            .overlaySpec {
                self.keyboardHeight > 50 &&
                UIDevice.current.userInterfaceIdiom == .phone ?
                    self.dismissKey
                        .insetSpec(10)
                        .relativeSpec(
                            horizontalPosition  : .end,
                            verticalPosition    : .end,
                            sizingOption        : .minimumSize) :
                ASSpacing()
            }//overlaySpec
            .insetSpec(
                UIScreen.main.safeAreaInset(
                    bottom: self.keyboardHeight
            ))//insetSpec
    }
    
}//ReKeyboardAwareNode
