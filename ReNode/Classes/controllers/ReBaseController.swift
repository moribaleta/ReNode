//
//  ReactiveBaseController.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import ReSwift

/**
 base view controller that implements:
 * Store Subscriber
 * Reactive Binding
 
 parameters:
 - E : Store State Type
 - T : State Type
 - V : UIView
 
 * NOTES:
    * ui view setup/rerender should be perform before super.viewDidLoad
        * recommended :
            * perform setup in loadView
 */
open class ReBaseController<E, T, V>: ASDKViewController<ASDisplayNode>, StoreSubscriber where E : StateType {

    ///contains the store state being used be the view controller
    public var store : Store<E>?
    
    ///used for emiting state changes from the store to the uiview binded to it
    public var statePublisher = PublishSubject<T>()
    
    ///used for clearing observable subscription
    public var reDisposedBag  = DisposeBag()
    
    ///current state of the store
    public var cache : T?
    
    ///exposed Specific ASDisplay Node passed from V casted from generic ASDisplayNode
    public var reNode : V! {
        return self.node as! V
    }
    
    public convenience init(reNode: V) {
        self.init(node: reNode as! ASDisplayNode)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        (self.node as? ReNode<T>)?.reactiveBind(obx: self.statePublisher)
        store?.subscribe(self)
    }
    
    @available(*, deprecated, message: "used onStateUpdate to listen to state changes without add super on override here", renamed: "onStateUpdate")
    open func newState(state: E) {
        if let state = extractStoreState(state: state) {
            self.onStatePreRender(state: state)
            self.statePublisher.onNext(state)
            self.onStateUpdate(state: state)
        }
    }
    
    ///override this function to listen to state changes
    open func onStateUpdate(state: T){
        
    }
    
    ///override this function to listen to state changes before the state is published
    open func onStatePreRender(state: T) {
        self.cache = state
    }
    
    ///override function to implement state change on substate
    open func extractStoreState(state: E) -> T? {
        return state as? T
    }
    
}//ReactiveBaseController

open class ReSingleStateController<E, V> : ReBaseController<E,E,V> where E : StateType {
    
    ///override this function to listen to state changes
    open override func onStateUpdate(state: E){
        super.onStateUpdate(state: state)
    }
    
    ///override this function to listen to state changes before the state is published
    open override func onStatePreRender(state: E) {
        
    }
    
}




