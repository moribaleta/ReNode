//
//  ReactiveNode.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

/**
 generic base UIView extends ASDisplayNode
 for reactive display changes
 - attention:
 - extend this class
 - T : state / object to bind to the ui
 */
open class ReactiveNode<T> : ResizeableNode {
    
    /// disposebag for current node
    public var disposeBag       = DisposeBag()
    
    /**
     * used for unsubscribing to the previous observable - reinitialized on reactiveBind
     * * NOTE: dont use outside of reactiveBind
     */
    public var reDisposeBag     = DisposeBag()
    
    /// used to determine if the view is initialize or not
    public var isInitial        = true;
    
    /// used to determine if the view should relayout on props did change
    public var relayoutOnPropsDidChange : Bool = false
    
    ///current props
    public var props : T? {
        internal_props
    }
    
    private(set) var internal_props : T?

    
    
    ///binds the observable to the component
    open func reactiveBind(obx: Observable<T>) {
        
        reDisposeBag = DisposeBag()
        
        obx
        .subscribe(onNext: { [weak self] emission in
            if (self?.isInitial ?? true) {
                self?.renderState(value: emission);
                self?.isInitial = false;
            } else {
                self?.reactiveUpdate(value: emission)
            }
            self?.onPropsDidSet(props: emission)
        }).disposed(by: reDisposeBag)
        
    }//reactiveBind
    
    
    /**
     overrider function to render this view
     - parameters:
     - value : new changes added
     */
    open func renderState(value: T) {
        
    }
    
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
     called after renderstate and reactiveupdate
     * parameters:
     - props  : Latest emission of the Props
     */
    open func onPropsDidSet(props: T) {
        self.internal_props = props
        if self.relayoutOnPropsDidChange {
            self.setNeedsLayout()
        }
    }
    
    
}//ReactiveNode


open class SeNode<T> : ReactiveNode<T> where T : Hashable {
    
    public var propsEmitter = RePropRelay<T>()
    
    open func reactiveBind(ps: RePropRelay<T>) {
        self.reactiveBind(
            obx: self.propsEmitter.asObservable()
                .unwrap()
                .distinctUntilChanged()
                .observe(on: MainScheduler.asyncInstance)
        )
        (self.propsEmitter <-> ps)
            .disposed(by: self.reDisposeBag)
    }
    
}



infix operator <->

@discardableResult public func <-><T>(property: RePropRelay<T>, variable: RePropRelay<T>) -> Disposable {
    let variableToProperty = variable.asObservable()
        .unwrap()
        .observe(on: MainScheduler.asyncInstance)
        .bind(to: property)

    let propertyToVariable = property
        .asObservable()
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(
            onNext: { variable.accept($0) },
            onCompleted: { variableToProperty.dispose() }
    )

    return Disposables.create(variableToProperty, propertyToVariable)
}

@discardableResult public func <-><T>(property: RePropRelay<T>, variable: PublishRelay<T>) -> Disposable {
    let variableToProperty = variable.asObservable()
        .bind(to: property)

    let propertyToVariable = property
        .asObservable()
        .unwrap()
        .subscribe(
            onNext: { variable.accept($0) },
            onCompleted: { variableToProperty.dispose() }
    )

    return Disposables.create(variableToProperty, propertyToVariable)
}

@discardableResult public func <-><T>(property: RePropRelay<T>, variable: BehaviorRelay<T>) -> Disposable {
    let variableToProperty = variable.asObservable()
        .bind(to: property)

    let propertyToVariable = property
        .asObservable()
        .unwrap()
        .subscribe(
            onNext: { variable.accept($0) },
            onCompleted: { variableToProperty.dispose() }
    )

    return Disposables.create(variableToProperty, propertyToVariable)
}


@discardableResult public func <-><T>(property: ControlProperty<T>, variable: PublishRelay<T>) -> Disposable {
    let variableToProperty = variable.asObservable()
        .bind(to: property)

    let propertyToVariable = property
        .subscribe(
            onNext: { variable.accept($0) },
            onCompleted: { variableToProperty.dispose() }
    )

    return Disposables.create(variableToProperty, propertyToVariable)
}

@discardableResult public func <-><T>(property: ControlProperty<T>, variable: RePropRelay<T>) -> Disposable {
    let variableToProperty = variable.asObservable()
        .unwrap()
        .bind(to: property)

    let propertyToVariable = property
        .subscribe(
            onNext: { variable.accept($0) },
            onCompleted: { variableToProperty.dispose() }
    )

    return Disposables.create(variableToProperty, propertyToVariable)
}
