//
//  ReactiveProtocol.swift
//  
//
//  Created by Gabriel Mori Baleta on 12/22/21.
//

import Foundation
import RxSwift

/**
 reactive protocol that implements binding and update
 */
public protocol ReactiveProtocol : class {
    
    associatedtype StateType
    
    @available(*, deprecated, message: "please use reactiveBind")
    func reBind(obx: Observable<StateType>)
    
    @available(*, deprecated, message: "please use reactiveUpdate")
    func reUpdate(value: StateType)
    
    func reactiveBind(obx: Observable<StateType>)
    
    func reactiveUpdate(value: StateType)
    
}//ReactiveProtocol

public extension ReactiveProtocol {
    
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
