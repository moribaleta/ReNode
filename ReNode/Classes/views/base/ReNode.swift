//
//  ReNode.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift


/**
 generic base UIView extends ASDisplayNode
 for reactive display changes
 - attention:
    - extend this class
    - T : state / object to bind to the ui
 */
open class ReNode<T> : ResizeableNode {
    
    /// disposebag for current node
    public var disposeBag       = DisposeBag()
    
    /// used for unsubscribing to the previous observable
    public var reDisposeBag     = DisposeBag()
    
    /// used to determine if the view is initialize or not
    public var isInitial   = true;
    
    fileprivate(set) var internal_props : T?
    
    ///current props
    public var props : T? {
        self.internal_props
    }
    
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    /**
        called before renderstate and reactiveupdate
        * parameters:
            - props  : Latest emission of the Props
     */
    open func seOnPropsDidSet(props: T) {
        self.internal_props = props
    }

    ///binds the observable to the component
    open func reactiveBind(obx: Observable<T>) {
        
        reDisposeBag = DisposeBag()
        
        obx.do(onNext: {
                [unowned self] in
                self.seOnPropsDidSet(props: $0)
            })
            .subscribe(onNext: { [weak self] emission in
                if (self?.isInitial ?? true) {
                    self?.renderState(value: emission);
                    self?.isInitial = false;
                } else {
                    self?.reactiveUpdate(value: emission)
                }
            }).disposed(by: reDisposeBag)
        
    }//reactiveBind
    
    /**
     override function to implement customize rendering on change state
        - default renderState is called
        - parameters:
            - value : new changes added
     */
    open func reactiveUpdate(value: T) {
        self.renderState(value: value)
    }
    
    /**
    overrider function to render this view
     - parameters:
        - value : new changes added
     */
    open func renderState(value: T) {
        
    }
    
}//ReactiveNode
