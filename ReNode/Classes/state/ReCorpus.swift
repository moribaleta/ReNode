//
//  ReThunk.swift
//
//
//  Created by Gabriel Mori Baleta on 8/4/21.
//

import Foundation
import ReSwift
import ReSwiftThunk


/**
 * basic definition of ReCorpus
 */
public protocol ReCorpusBase : Action {
    var  name       : String {get}
    func body<State>(_ dispatch: @escaping DispatchFunc, _ getState: @escaping () -> State?) -> Void
}

/**
 * protocol implements thunk operation
 */
public protocol ReCorpus : ReCorpusBase {
    associatedtype State : StateType
    func execute(dispatch: @escaping DispatchFunc, getState: GetState) -> Void
}

public typealias DispatchFunc = DispatchFunction

public extension ReCorpus {
    
    typealias GetState          = () -> State?
    typealias DispatchBody      = (@escaping  DispatchFunc, GetState) -> ()
    typealias Dispatcher        = DispatchFunction
    
    var name: String {
        return String(describing: self)
    }
    
    func body<State>(_ dispatch: @escaping DispatchFunc, _ getState: @escaping () -> State?) {
        self.execute(dispatch: dispatch) {
            return getState() as? Self.State
        }
    }
    
}//ReCorpus

/*
 * convenience model for creating quick corpus action without extended ReCorpus or ReCorpusBase
 */
public struct ReCorpusAction<T> : ReCorpusBase where T : StateType {
    
    public typealias callable   = ((_ dispatch : @escaping DispatchFunc, _ getState: () -> T?) -> Void)
    
    public var name             : String

    public var execute          : callable
    
    public func body<State>(_ dispatch: @escaping DispatchFunc, _ getState: @escaping () -> State?) {
        self.execute(dispatch) {
            return getState() as? T
        }
    }
    
    public init(name: String, execute: @escaping callable) {
        self.name       = name
        self.execute    = execute
    }
}

public class StateUtilities {
    
    ///packages all middleware in a single array
    public static func Middleware<T>(_ middlewares: [Middleware<T>] = []) -> [Middleware<T>] {
        [
            CreateCorpusMiddleWare(),
            createThunkMiddleware(),
        ] + middlewares
    }
    
    
    public static func CreateCorpusMiddleWare<T>() -> Middleware<T> {
        return {
            dispatch, getState in
            return { next in
                return { action in
                    switch action {
                    case let corpus as ReCorpusBase:
                        corpus.body(dispatch, getState)
                    default:
                        next(action)
                    }
                }
            }
        }
    }//CreateCorpusMiddleWare
    
}

