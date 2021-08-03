//
//  Observables.swift
//  ReNodeSample
//
//  Created by Gabriel Mori Baleta on 7/30/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public enum DispatchScheduler {
    case main
    case this(queue: DispatchQueue)
    case background
}


class __PreviousState<E> {
    var lastValue: E?
}

public extension ObservableType {

    /**
     Provides SeriousMD with creating an easy way of selecting which thread to run on.
     
     Use `concat` operator afterwards, not `flatMap`, because this class uses `Observable.empty`
     instead of `Observable.just`.
     
     - Parameter thread: Which thread to run on, either `main`, `sync`, or `background`.
     - Returns: An Observable operation
     */
    
     static func run<E>(on thread: DispatchScheduler) -> Observable<E> {
        switch thread {
        case .background:
            return Observable.empty()
                .observe(on: ConcurrentDispatchQueueScheduler(queue: AsyncTaskUtil.background))
            
        case .main:
            return Observable.empty()
                .observe(on: MainScheduler.instance)
            
        case .this (let queue):
            return Observable.empty()
                .observe(on: SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: queue.label))
        }
    }
    
    /**
     Subscribes on the background thread and observes on the main thread. Does work in the background and returns to the main thread afterwards.
     - Authors: Darren Sapalo
     */
     func applyBasicSchedulers() -> Observable<Self.Element> {
        return subscribe(on: ConcurrentDispatchQueueScheduler.init(queue: AsyncTaskUtil.background))
            .observe(on: MainScheduler.instance)
    }
    
    /**
     Subscribes on the background thread and observes on the main thread. Does work in the background and returns to the main thread afterwards.
     - Authors: Darren Sapalo
     */
     func subscribeOnBackground(_ queue: DispatchQueue = AsyncTaskUtil.background) -> Observable<Self.Element> {
        return subscribe(on: ConcurrentDispatchQueueScheduler(queue: queue))
            .observe(on: MainScheduler.instance)
    }
    
    /**
    used to add delay -- for alert controllers
     - Authors: Mori Baleta
     */
    func onDelay(_ delay: RxTimeInterval = .milliseconds(300)) -> Observable<Self.Element> {
        return Observable<Void>.just(())
            .delay(delay, scheduler: MainScheduler.asyncInstance)
            .flatMap({self})
    }
    
    /**
     Subscribes on the background thread and observes on the main thread. Does work in the background and returns to the main thread afterwards.
        uses Serial Dispatcher
     - Authors: Mori Baleta
     */
     func subscribeOnScheduler(_ queue: SerialDispatchQueueScheduler = MainScheduler.asyncInstance) -> Observable<Self.Element> {
        return subscribe(on: queue)
            .observe(on: MainScheduler.instance)
    }
    
    /**
        converts obs to be nullable
     */
     func nullable() -> Observable<Self.Element?> {
        return self.map { (entry) -> Self.Element? in
            return entry
        }
    }
    
    ///if you wish to just subscribe to the obs without doing anything
    func subscribe(disposer: DisposeBag) {
        self.subscribe().disposed(by: disposer)
    }
    
    ///call on next without the hassle of having onCompleted and onError showing similar to `bind(onNext:)`
    func doNext(_ onNext: @escaping (Element) -> Void) -> Observable<Self.Element>{
        return self.do(onNext: {
            onNext($0)
        })
    }
    
    ///call on error separated from do
    func doError(_ onError: @escaping (Error) -> Void) -> Observable<Self.Element> {
        return self.do(onError: {
            onError($0)
        })
    }
    
    /**
        observable for string inputs
        combines throttle and distinctUntilChanged
     */
    func throttleDistinctText(_ time: RxTimeInterval     = .milliseconds(300),
                                 scheduler: SchedulerType   = ConcurrentMainScheduler.instance) -> Observable<Self.Element> where Self.Element == String? {
        return self.throttle(time, scheduler: scheduler)
            .distinctUntilChanged()
    }
    

    /**
     Do you need to convert the observable stream into an operation without aggregating? This is the method for it!

     Unlike `asOperation()` this won't aggregate emissions from the source observable.

     */
     func toOperation() -> Observable<Void> {
        return self.map({ _ -> Void in () })
    }
    
    
    /**
        uses filter operation then return void on true
     */
    func filterToOperation(_ where: @escaping (Element)->(Bool)) -> Observable<Void> {
        return self.filter { e in
            return `where`(e)
        }.toOperation()
    }
    
    /**
     This operation combines the current emission with its last emission. It will not send an event until there are two emissions from the source observable.
     - Returns: An observable stream with a tuple of the `old` and the `new` value.
     - Authors: Michael Ong
     */
    func combinePrevious(with initialValue: Element? = nil) -> Observable<(old: Element, new: Element)> {

        let outside         = self

        let state           = __PreviousState<Element>()
            state.lastValue = initialValue

        return Observable.create { (observer) -> Disposable in
            outside.subscribe   { value in
                guard let last = state.lastValue else {
                    state.lastValue = value
                    return
                }

                observer.on(.next((old: last, new: value)))
                state.lastValue = value
            } onError:          { error in
                // forward error
                observer.on(.error(error))
            } onCompleted:      {
                observer.on(.completed)
            } onDisposed:       {
            }
        }
    }
    
    func asBehaviorRelay(scope: DisposeBag, initialValue: Element) -> BehaviorRelay<Element> {
        let relay = BehaviorRelay(value: initialValue)
        bind(to: relay).disposed(by: scope)

        return relay
    }
    
    
     func doOnTerminate(terminator: @escaping (() -> Void)) -> Observable<Element> {
        return Observable.create { obx in
            
            return self.subscribe { e in
                switch e {
                case .completed:
                    terminator()
                    obx.onCompleted()
                case .error(let err):
                    terminator()
                    obx.onError(err)
                case .next(let e):
                    obx.onNext(e)
                }
            }
        }
        
    }
    
}

// MARK : Dictionary observables


 public extension ObservableType where Element == Data {
    func toString() -> Observable<String> {
        return Observable.create { obx in
            return self.subscribe{ e in
                
                switch e {
                case .completed:
                    obx.onCompleted()
                case .error(let err):
                    obx.onError(err)
                case .next(let data):
                    
                    if let result = String(data: data, encoding: String.Encoding.utf8) {
                        obx.onNext(result)
                    }else {
                        print("Failed to convert Data to String.")
                        obx.onError(RxError.unknown)
                    }
                    
                }
            }
        }
    }

}

public extension ObservableType where Element == AnyObject {
    
    func toData() -> Observable<Data> {
        return self.map { object in
            return try JSONSerialization.data(withJSONObject: object, options: [])
        }
    }
}

public extension ObservableType where Element == [[String: Any]] {
    func toData() -> Observable<Data> {
        return self.map { object in
            return try JSONSerialization.data(withJSONObject: object, options: [])
        }
    }
}

public extension ObservableType where Element == NSString {
    func toData() -> Observable<Data> {
        return self.map { string in
            if let nsData = string.data(using: String.Encoding.utf8.rawValue) {
                return nsData
            }else {
                print("Failed to create NSData from NSString.")
                throw RxError.unknown
            }
        }
    }
}

public extension ObservableType {
    
    func flatMapConditional<T> (condition: @escaping (Self.Element) -> Bool, _ true: @escaping (Self.Element)-> Observable<T>, false: @escaping (Self.Element) -> Observable<T>) -> Observable<T> {
        self.flatMap { val in
            condition(val) ?
                `true`(val) :
                `false`(val)
        }
    }
    
    func mapConditional<T> (condition: @escaping (Self.Element) -> Bool, _ true: @escaping (Self.Element)-> T, false: @escaping (Self.Element) -> T) -> Observable<T> {
        self.map { val in
            condition(val) ?
                `true`(val) :
                `false`(val)
        }
    }
    
}

public extension ObservableType where Element == Bool {
    
    func doLogic (_ true: @escaping ()->Void,_ else: @escaping ()->Void ) -> Observable<Void> {
        return self.do(onNext:{ value in
            if value {
                `true`()
            } else {
                `else`()
            }
        }).toOperation()
    }
    
    func doTrue (_ true: @escaping ()->Void) -> Observable<Element> {
        return self.do(onNext:{ value in
            if value {
                `true`()
            }
        })
    }
    
    func doFalse (_ false: @escaping ()->Void) -> Observable<Element> {
        return self.do(onNext:{ value in
            if !value {
                `false`()
            }
        })
    }
}


