//
//  ReProtocol.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift

/**
 ###NOTE
 - create a way to determine if the current view is still in initialize
 - determine if the value change is from a user or from the state change
 - determine if the value has change
 */


/**
    reactive protocol that implements binding and update
 */
public protocol ReProtocol : class {
    
    associatedtype StateType
    
    @available(*, deprecated, message: "please use reactiveBind")
    func reBind(obx: Observable<StateType>)
    
    @available(*, deprecated, message: "please use reactiveUpdate")
    func reUpdate(value: StateType)
    
    func reactiveBind(obx: Observable<StateType>)
    
    func reactiveUpdate(value: StateType)
    
}//ReactiveProtocol

public extension ReProtocol {
    
    func reactiveBind(obx: Observable<StateType>) {
        
    }
    
    func reactiveUpdate(value: StateType) {
        
    }
    
    @available(*, deprecated, message: "please use reactiveBind")
    func reBind(obx: Observable<StateType>) {
        
    }
    
    @available(*, deprecated, message: "please use reactiveUpdate")
    func reUpdate(value: StateType) {
        
    }
    
}
