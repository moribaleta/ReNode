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

// MARK : Generic Observables

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
    
    public static func run<E>(on thread: DispatchScheduler) -> Observable<E> {
        switch thread {
        case .background:
            return Observable.empty()
                .observeOn(ConcurrentDispatchQueueScheduler(queue: AsyncTaskUtil.background))
            
        case .main:
            return Observable.empty()
                .observeOn(MainScheduler.instance)
            
        case .this (let queue):
            return Observable.empty()
                .observeOn(SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: queue.label))
        }
    }
    
    /**
     Subscribes on the background thread and observes on the main thread. Does work in the background and returns to the main thread afterwards.
     - Authors: Darren Sapalo
     */
    public func applyBasicSchedulers() -> Observable<Self.E> {
        return subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: AsyncTaskUtil.background))
            .observeOn(MainScheduler.instance)
    }
    
    /**
     Subscribes on the background thread and observes on the main thread. Does work in the background and returns to the main thread afterwards.
     - Authors: Darren Sapalo
     */
    public func subscribeOnBackground(_ queue: DispatchQueue = AsyncTaskUtil.background) -> Observable<Self.E> {
        return subscribeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .observeOn(MainScheduler.instance)
    }
    
    /**
    used to add delay -- for alert controllers
     - Authors: Mori Baleta
     */
    func onDelay(_ delay: RxTimeInterval = 0.3) -> Observable<Self.E> {
        return Observable<Void>.just(())
            .delay(delay, scheduler: MainScheduler.asyncInstance)
            .flatMap({self})
    }
    
    /**
     Subscribes on the background thread and observes on the main thread. Does work in the background and returns to the main thread afterwards.
        uses Serial Dispatcher
     - Authors: Mori Baleta
     */
    public func subscribeOnScheduler(_ queue: SerialDispatchQueueScheduler = MainScheduler.asyncInstance) -> Observable<Self.E> {
        return subscribeOn(queue)
            .observeOn(MainScheduler.instance)
    }
    
    /**
        converts obs to be nullable
     */
    public func nullable() -> Observable<Self.E?> {
        return self.map { (entry) -> Self.E? in
            return entry
        }
    }
    
    ///if you wish to just subscribe to the obs without doing anything
    func subscribe(disposer: DisposeBag) {
        self.subscribe().disposed(by: disposer)
    }
    
    ///call on next without the hassle of having onCompleted and onError showing similar to `bind(onNext:)`
    func doNext(_ onNext: @escaping (E) -> Void) -> Observable<Self.E>{
        return self.do(onNext: {
            onNext($0)
        })
    }
    
    ///call on error separated from do
    func doError(_ onError: @escaping (Error) -> Void) -> Observable<Self.E> {
        return self.do(onError: {
            onError($0)
        })
    }
    
    /**
        observable for string inputs
        combines throttle and distinctUntilChanged
     */
    public func throttleDistinctText(_ time: RxTimeInterval     = 0.3,
                                 scheduler: SchedulerType   = ConcurrentMainScheduler.instance) -> Observable<Self.E> where Self.E == String? {
        return self.throttle(time, scheduler: scheduler)
            .distinctUntilChanged()
    }
    
    
    /**
     Wow, it seems you're stuck in RxWorld and you want to get out, just wanting to see if an operation was successful or not.
     Well here you go, this will return true!
     
     - Returns : true if the operation did not encounter any error.
     */
    @available(*, deprecated)
    public func isSuccessful() -> Bool {
        let result : Bool? = self.map { _ in true }.optional()
        return result ?? false
    }
    
    /**
     Don't need the results? Turn it into an `Observable<Void>`.
     
     This assumes that the observable sequence completes (because it uses the `toArray()` operator)
     and that the resulting type is `Void`.
     */
    public func asOperation() -> Observable<Void> {
        return self
            .toArray()
            .map { _ in Void() }
    }

    /**
     Do you need to convert the observable stream into an operation without aggregating? This is the method for it!

     Unlike `asOperation()` this won't aggregate emissions from the source observable.

     */
    public func toOperation() -> Observable<Void> {

        return self.map({ _ -> Void in () })
    }
    
    
    /**
        uses filter operation then return void on true
     */
    func filterToOperation(_ where: @escaping (E)->(Bool)) -> Observable<Void> {
        return self.filter { e in
            return `where`(e)
        }.toOperation()
    }
    
    /**
     This operation combines the current emission with its last emission. It will not send an event until there are two emissions from the source observable.
     - Returns: An observable stream with a tuple of the `old` and the `new` value.
     - Authors: Michael Ong
     */
    func combinePrevious(with initialValue: E? = nil) -> Observable<(old: E, new: E)> {

        let outside         = self

        let state           = __PreviousState<E>()
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
    
    func asBehaviorRelay(scope: DisposeBag, initialValue: E) -> BehaviorRelay<E> {
        let relay = BehaviorRelay(value: initialValue)
        bind(to: relay).disposed(by: scope)

        return relay
    }
    
    /**
     Performs a subscription that returns the first emission from this Observable sequence.
     For example, this method converts an `Observable<Doctor>` into a `Doctor` unless it takes
     longer than 5 seconds to get it.
     
     Note that this subscription performs a timeout after 5 seconds.
     
     The blocking mechanism used is a semaphore.
     - Parameter timeout : Duration in seconds.
     */
    @available(*, deprecated)
    public func optional(timeout: Double? = nil) -> E? {
        guard let timeout = timeout else {
            do {
                if let result = try self.toBlocking(timeout: 5).first() {
                    return result
                }
            } catch {
                
            }
            return nil
        }
        
        do {
            if let result = try self.toBlocking(timeout: timeout).first() {
                return result
            }
        } catch {
            
        }
        return nil
    }
    
    /**
     Performs a subscription that returns the first emission from this Observable sequence.
     For example, this method converts an `Observable<Doctor>` into a `Doctor` unless it takes
     longer than 5 seconds to get it.
     
     Note that this subscription performs a timeout after 5 seconds.
     
     The blocking mechanism used is a semaphore.
     - Parameter timeout : Duration in seconds.
     */
    @available(*, deprecated)
    public func optionalWithErrors(timeout: Double? = nil) throws -> E? {
        guard let timeout = timeout else {
            if let result = try self.toBlocking(timeout: 5).first() {
                return result
            }
            return nil
        }
        
        if let result = try self.toBlocking(timeout: timeout).first() {
            return result
        }
        
        return nil
    }
    
    public func doOnTerminate(terminator: @escaping (() -> Void)) -> Observable<E> {
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
    
    /**
     
     Throttles emissions by 250 milliseconds. The main scheduler instance is used to schedule the throttle checking.
     
     */
    
    @available(*, deprecated, renamed: "throttleDistinctText")
    public func throttleForTextInput() -> Observable<E> {
        
        return self.throttle(0.25, scheduler: MainScheduler.instance)
    }
}

// MARK : Dictionary observables


public extension ObservableType where E == Data {
    public func toString() -> Observable<String> {
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
    
    public func toJsonSerialized<R>() -> Observable<R> {
        return self.map { data in
            
            let json = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableContainers]) as? R
            
            if let j = json {
                return j
            } else {
                print("\n\nFailed to convert Data to Array.")
                print("Data was: ")
                let debugData = String(data: data, encoding: String.Encoding.utf8) ?? "Could not be parsed"
                print(debugData)
                throw SerializationError.unknown(data: data)
            }
            
        }
    }
}

public extension ObservableType where E == AnyObject {
    
    public func toJsonSerialized<R>() -> Observable<R> {
        return self.map { data in
                do {
                    var nsData : Data? = (data as? Data)
                    
                    if nsData == nil {
                        nsData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
                    }
                    
                    guard let theNsData = nsData else {
                        throw SerializationError.failed
                    }
                    
                    guard let json = try JSONSerialization.jsonObject(with: theNsData, options: JSONSerialization.ReadingOptions.mutableLeaves) as? R else {
                        throw SerializationError.failed
                    }
                    
                    return json
                    
                } catch (let error) {
                    throw error
                }
            }
    }
    
    public func toData() -> Observable<Data> {
        return self.map { object in
            return try JSONSerialization.data(withJSONObject: object, options: [])
        }
    }
}

public extension ObservableType where E == [[String: Any]] {
    public func toData() -> Observable<Data> {
        return self.map { object in
            return try JSONSerialization.data(withJSONObject: object, options: [])
        }
    }
}

public extension ObservableType where E == NSString {
    public func toData() -> Observable<Data> {
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

public extension ObservableType where E == NSDictionary {
    public func value<R>(forKey key: String) -> Observable<R> {
        
        return self.map { dictionary in
            guard let value = dictionary.value(forKey: key) as? R else {
                throw ParseError.keyNotFound(key: key)
            }
            return value
        }
    }
}

// TODO: Michael, we need to do RxLibsuture! AAAAHHH :D :D :D


public extension ObservableType where E == Bool {
    
    func doLogic (_ true: @escaping ()->Void,_ else: @escaping ()->Void ) -> Observable<Void> {
        return self.do(onNext:{ value in
            if value {
                `true`()
            } else {
                `else`()
            }
        }).asOperation()
    }
    
    func doTrue (_ true: @escaping ()->Void) -> Observable<E> {
        return self.do(onNext:{ value in
            if value {
                `true`()
            }
        })
    }
    
    func doFalse (_ false: @escaping ()->Void) -> Observable<E> {
        return self.do(onNext:{ value in
            if !value {
                `false`()
            }
        })
    }
}


