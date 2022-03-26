//
//  RePropRelay.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/14/22.
//

import Foundation
import RxSwift
import RxCocoa


public protocol RePropRelayType {
    associatedtype State
    var br      : BehaviorSubject<State?> {get set}
    var value   : State? {get}
}

/**
 wrapper for behavior subject can be disposed
 similar to behavior relay but can accept nullable value
 */
public final class RePropRelay<State> : RePropRelayType {
    
    public var br : BehaviorSubject<State?>
    
    public var rx : Observable<State?> {
        self.br.asObservable()
    }
    
    public var value : State? {
        do {
            return try br.value()
        } catch {
            return nil
        }
    }
    
    public init(value: State? = nil) {
        self.br = .init(value: value)
    }
    
    public func dispose() {
        self.br.dispose()
    }
    
    ///provides a callback that will return a new object to be updated to the variable
    public func update(callback: @escaping CallBack.typeCall<State?, State>) {
        let val = callback(self.value)
        self.br.onNext(val)
    }
    
    
    
    public func accept(_ val: State?) {
        self.br.onNext(val)
    }
    
}//RePropRelay

public extension RePropRelayType {
    
    ///converts type into an observable
    func asObservable() -> Observable<State?> {
        self.br.asObservable()
    }
    
}

public extension RePropRelayType where State : Hashable {
    
    ///provides a callback that will return a new object to be updated to the variable
    func update(callback: @escaping CallBack.typeCall<State?, State?>) {
        let val = callback(self.value)
        self.br.onNext(val)
    }
    
    func update<Input: Hashable>(key: WritableKeyPath<State, Input>, value: @escaping @autoclosure () -> Input,  defaultValue: @escaping @autoclosure () -> State) {
        var new : State     = self.value ?? defaultValue()
        new[keyPath: key]   = value()
        self.br.onNext(new)
    }
    
    func update<Input: Hashable>(key: WritableKeyPath<State, Input>, value: @escaping @autoclosure () -> Input) {
        guard var new : State     = self.value else {
            return
        }
        new[keyPath: key]   = value()
        self.br.onNext(new)
    }
    
    func update<Input: Hashable>(key: WritableKeyPath<State, Input>, value: @escaping @autoclosure () -> Input?, defaultInputValue: @escaping @autoclosure () -> Input) {
        guard var new : State     = self.value else {
            return
        }
        new[keyPath: key]   = value() ?? defaultInputValue()
        self.br.onNext(new)
    }
    
    func update<Input: Hashable>(key: WritableKeyPath<State, Input>, defaultInputValue: @escaping @autoclosure () -> Input, relay callback : CallBack.typeCall<RePropRelay<Input>, Disposable> ) -> Disposable {
        print(key)
        let state : State?  = self.value
        let initValue       = state?[keyPath: key]
        let relay           = RePropRelay<Input>(value: initValue)
        
        let obx = self.br.map{
            $0?[keyPath: key] as? Input
            }
            .unwrap()
            .distinctUntilChanged()
            .bind(onNext: {
                relay.accept($0)
            })
            
        
        return Disposables.create(
            callback(relay),
            obx,
            relay.asObservable()
                .distinctUntilChanged()
                .bind(onNext: {
                    val in
                    self.update { state in
                        var state = state
                        state?[keyPath : key] = val ?? defaultInputValue()
                        return state
                    }
                })
        )
    }
    
    func map<Input: Hashable>(key: WritableKeyPath<State, Input>, defaultInputValue: @escaping @autoclosure () -> Input) -> Observable<Input> {
        self.asObservable()
            .map { state -> Input in
                state?[keyPath: key] ?? defaultInputValue()
            }
    }
    
}



extension ObservableType {
    
    /**
    Creates new subscription and sends elements to observer.
    
    In this form it's equivalent to `subscribe` method, but it communicates intent better, and enables
    writing more consistent binding code.
    
    - parameter to: Observer that receives events.
    - returns: Disposable object that can be used to unsubscribe the observer.
    */
    public func bind<O: RePropRelayType>(to relayProp: O) -> Disposable where O.State == Element {
        return self.bind(to: relayProp.br)
    }
    
}


