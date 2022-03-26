//
//  ReBackgroundDisplay.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation
import AsyncDisplayKit

///uiview display the container view in a card view - with drop shadow
open class BackgroundDisplay: ResizeableNode {
    
    public var isShadowEnabled = true {
        didSet {
            if self.isShadowEnabled {
                self.onDefault()
            } else {
                self.layer.shadowOpacity = 0
            }
        }
    }
    
    public override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.isOpaque           = true
        self.backgroundColor    = UIColor.white
        self.cornerRadius       = 10
    }
    
    private func onPress() {
        self.layer.shadowRadius  = 5
        self.layer.shadowOpacity = 0.5
    }
    
    private func onDefault(){
        self.layer.shadowOpacity    = 0.5
        self.layer.shadowRadius     = 2.0
    }
    
    open override func didLoad() {
        //self.showShadow()
        self.dropShadowDefault()
    }
    
    public func showShadow() {
        self.onDefault()
        self.layer.shadowColor  = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    public func onTouch(highlighted: Bool){
        UIView.animate(withDuration: 1, animations: {
            if highlighted {
                self.onPress()
            }else{
                self.onDefault()
            }
            
        })
    }
    
}


open class ReBackgroundDisplay<T> : ReactiveNode<T> {
    
    public var isShadowEnabled = true {
        didSet {
            if self.isShadowEnabled {
                self.onDefault()
            } else {
                self.layer.shadowOpacity = 0
            }
        }
    }
    
    public override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.isOpaque           = true
        self.backgroundColor    = UIColor.white
        self.cornerRadius       = 10
    }
    
    private func onPress() {
        self.layer.shadowRadius  = 5
        self.layer.shadowOpacity = 0.5
    }
    
    private func onDefault(){
        self.layer.shadowOpacity    = 0.5
        self.layer.shadowRadius     = 2.0
    }
    
    open override func didLoad() {
        //self.showShadow()
        self.dropShadowDefault()
    }
    
    public func showShadow() {
        self.onDefault()
        self.layer.shadowColor  = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    public func onTouch(highlighted: Bool){
        UIView.animate(withDuration: 1, animations: {
            if highlighted {
                self.onPress()
            }else{
                self.onDefault()
            }
            
        })
    }
    
}




