//
//  RxSwift.swift
//  DoctorApp
//
//  Created by Darren Karl Sapalo on 06/12/2016.
//  Copyright © 2016 SeriousMD. All rights reserved.
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
    public func applyBasicSchedulers() -> Observable<Self.Element> {
        return subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: AsyncTaskUtil.background))
            .observeOn(MainScheduler.instance)
    }
    
    /**
     Subscribes on the background thread and observes on the main thread. Does work in the background and returns to the main thread afterwards.
     - Authors: Darren Sapalo
     */
    public func subscribeOnBackground(_ queue: DispatchQueue = AsyncTaskUtil.background, target: ImmediateSchedulerType = MainScheduler.instance) -> Observable<Self.Element> {
        return subscribeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .observeOn(target)
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
    public func subscribeOnScheduler(_ queue: SerialDispatchQueueScheduler = MainScheduler.asyncInstance) -> Observable<Self.Element> {
        return subscribeOn(queue)
            .observeOn(MainScheduler.instance)
    }
    
    /**
        converts obs to be nullable
     */
    public func nullable() -> Observable<Self.Element?> {
        return self.map { (entry) -> Self.Element? in
            return entry
        }
    }
    
    ///if you wish to just subscribe to the obs without doing anything
    func subscribe(disposer: DisposeBag) {
        self.subscribe().disposed(by: disposer)
    }
    
    ///called on subscribe started
    func doOnSubscribe(_ onSubscribe: @escaping () -> Void) -> Observable<Self.Element> {
        return self.do(
            onSubscribe: onSubscribe
        )
    }
    
    ///called on subscribe started with a dispatchqueue main block inside to ensure called on the main thread
    func doAsyncOnSubscribe(_ onSubscribe: @escaping () -> Void) -> Observable<Self.Element> {
        return self.do(
            onSubscribe: {
                DispatchQueue.main.async {
                    onSubscribe()
                }
            }
        )
    }
    
    ///call on next without the hassle of having onCompleted and onError showing similar to `bind(onNext:)`
    func doNext(_ onNext: @escaping (Element) -> Void) -> Observable<Self.Element>{
        return self.do(onNext: {
            onNext($0)
        })
    }
    
    ///call on next same as doNext but wrapped the operation in DispatchQueue.main.async
    func doAsyncNext( _ onNext: @escaping (Element) -> Void) -> Observable<Self.Element> {
        return self.doNext {
            val in
            DispatchQueue.main.async {
                onNext(val)
            }
        }
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
     Don't need the results? Turn it into an `Observable<Void>`.
     
     This assumes that the observable sequence completes (because it uses the `toArray()` operator)
     and that the resulting type is `Void`.
     */
    /*func asOperation() -> Observable<Void> {
        return self
            .toArray()
            .compactMap { [] -> Void in
                return ()
            }
        
    }*/

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
    
    /*func toJsonSerialized<R>() -> Observable<R> {
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
    }*/
}

public extension ObservableType where Element == AnyObject {
    
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

public extension ObservableType where Element == [[String: Any]] {
    public func toData() -> Observable<Data> {
        return self.map { object in
            return try JSONSerialization.data(withJSONObject: object, options: [])
        }
    }
}

public extension ObservableType where Element == NSString {
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

public extension ObservableType where Element == NSDictionary {
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

public extension ObservableType {
    
    typealias CallBackType<T, V> = (T) -> V
    
    ///converts the flatmap of an observable type to a void calls .just(void) if false is not provided
    func flatMapOperational(_ condition: @escaping (Self.Element) -> Bool, true: @escaping (Self.Element)-> Observable<Void>, false: ((Self.Element) -> Observable<Void>)? = nil) -> Observable<Void> {
        self.flatMap { val in
            (condition(val) ?
                `true`(val) :
                (`false`?(val)) ?? .just(()))
        }
    }
    
    ///converts the flatmap of an observable type to a void calls .just(void) if `false` is not provided
    func flatMapUnwrapOperational<T>(
        _ keySelector: @escaping CallBackType<Self.Element, T?>,
        true    : @escaping CallBackType<T, Observable<Void>>,
        false   : CallBackType<Void, Observable<Void>>? = nil) -> Observable<Void> {
            
        self.flatMap { val -> Observable<Void> in
            if let val = keySelector(val) {
                return `true`(val)
            } else {
                return `false`?(()) ?? .just(())
            }
        }
    }
    
    func flatMapConditional<T> (_ condition: @escaping (Self.Element) -> Bool, true: @escaping (Self.Element)-> Observable<T>, false: @escaping (Self.Element) -> Observable<T>) -> Observable<T> {
        self.flatMap { val in
            condition(val) ?
                `true`(val) :
                `false`(val)
        }
    }
    
    func mapConditional<T> (_ condition: @escaping (Self.Element) -> Bool, true: @escaping (Self.Element)-> T, false: @escaping (Self.Element) -> T) -> Observable<T> {
        self.map { val in
            condition(val) ?
                `true`(val) :
                `false`(val)
        }
    }
    
    /**
     * combines filter and map
     * returns the filtered data
     * ```
     * Observable<String?>.just("me")
     *  .filter{$0 != nil}
     *  .map{$0!}
     * ```
     */
    func filterMap<T>(key: @escaping (Self.Element)-> T?) -> Observable<T> {
        self.filter { e in
            return key(e) != nil
        }.map { e in
            return key(e)!
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

public extension Observable {

    /// Returns an `Observable` where the nil values from the original `Observable` are skipped
    func unwrap<T>() -> Observable<T> where Element == T? {
        self.filter { $0 != nil }
            .map { $0! }
    }
}




//
//  Errors.swift
//  ReNodeSample
//
//  Created by Gabriel Mori Baleta on 12/22/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

//import Foundation
//import RxSwift




