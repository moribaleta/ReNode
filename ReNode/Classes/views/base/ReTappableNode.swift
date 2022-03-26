//
//  CommonTappableNode.swift
//  ReNode
//
//  Created by Mini on 2/21/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift

/**
 * class inherits from ReButton
 * - used for creating simple view inside a tappable view
 */
open class ReTappableNode : ReButton {
    
    ///content being displayed
    public var content  : ASDisplayNode = .init()
    
    public var layoutContent   : CallBack.typeCall<ASSizeRange, ASLayoutSpec>? = nil
    
    
    public override  init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true 
    }
    
    /**
     * create an instance of tappable node
     * * parameters:
     *      * content : the view to be displayed
     *      * callback: can directly used this callback to receive tap function
     */
    public convenience init(content: ASDisplayNode, callback: CallBack.void? = nil) {
        self.init()
        
        self.content = content
        
        if let callback = callback {
            self.rxTap
                .bind {
                    callback()
                }.disposed(by: self.disposeBag)
        }
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.layoutContent?(constrainedSize) ??
        ASWrapperLayoutSpec {
            self.content
        }
    }

    
    
}//CommonTappableNode
