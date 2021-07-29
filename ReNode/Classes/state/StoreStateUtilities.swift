//
//  StoreStateUtilities.swift
//  SMDModuleUtility
//
//  Created by Gabriel on 25/09/2019.
//  Copyright © 2019 Leapfroggr Inc. All rights reserved.
//

import Foundation
import ReSwift


///the proper reducer used for ReSwift on creating a store
public typealias SealedReducer<T> = (Action, T?) -> T

///reducer that returns an optional type for piping reducers into reducer
public typealias StateReducer<T> = (Action,T?) -> T?

///state reducer that returns specific StateType
public typealias ReStateReducer   = (Action, StateType?) -> StateType?
//public typealias ReSealedReducer  = (Action, StateType?) -> StateType


/**
 protocol for implementing states with substates
 */
public protocol ComposedStateType {
    ///returns the substate from the the main state
    func get(key: String, action: Action) -> StateType?
    ///changes the substate from the main state
    mutating func set(key: String, action: Action, value: StateType?)
}

/**
 * protocol for implementing states with substates extends on ComposedStateType
 * * strict associatedtype : E - StateType
 * * substates used to contain the substates used
 */
public protocol ComposedHashedStateType : ComposedStateType {
    var substate : [String : StateType] {get set}
}


/**
 function for combining multiple reducer into one reducer for the Store
```
 let composedReducer = composeReducer(funcs:  reducer1, reducer2, ...)
 ```
 */
public func ComposeReducer<T>(funcs: StateReducer<T>...) -> StateReducer<T> {
    return {
        (action: Action, state: T?) -> T? in
        
        return funcs.reduce(state, { (result, reducer2) -> T? in
            return reducer2(action, result)
        })
        
    }
}


/**
 function for combining multiple reducer into one reducer for the Store
 ```
 let composedReducer = composeReducer(funcs:  reducer1, reducer2, ...)
 ```
 */
public func ComposeSealedReducer<T>(funcs: SealedReducer<T>...) -> SealedReducer<T> {
    return {
        (action: Action, state: T?) -> T in
        return funcs.reduce(state, { (result, reducer2) -> T in
            return reducer2(action, result)
        })!
    }
}



/**
 wraps the StateReducer<T> into a proper SealedReducer<T>
 * where the T in StateReducer is optional
 * and the T in the SealedReducer is required to not be optional in creating a store
 */
public func SealReducer<T>(reducer: @escaping StateReducer<T>) -> (Action,T?) -> T {
    return { (action, state) -> T in
        return reducer(action, state)!
    }
}


/**
 combines all substate reducer to be executed on the appropriate main state's substates
    - returns a single a single composite reducer
    * Parameters:
        - funcs
            - is a dictionary of ReStateReducer that is a reducer to be executed
            - the key refers to the substate key identifier string
 */
public func BranchReducer<T>(funcs: [String: ReStateReducer]) -> (Action,T?) -> T? where T : StateType {
    return { (action: Action,state: T?) -> T? in
        guard let composedState = state as? ComposedStateType
            else { return state }//fatalError("State Reducer cannot be branched") }
        
        ///reduces all the reducer functions by accessing the keys from funcs
        return funcs.keys.reduce(composedState, {
            (result, key) -> ComposedStateType in
            
            ///the main state
            var result = result
            if let reducer = funcs[key] {
                ///gets the current substate from the main state
                let oldSubstate = result.get(key: key, action: action)
                
                ///execute the reducer with the substate
                let newSubstate = reducer(action, oldSubstate)
                
                ///sets the value to the main state
                result.set(key: key, action: action, value: newSubstate)
            }
            return result
            
        }) as? T// as! T
    }
}//branchReducer


/**
    transform the StateReducer<T> into ReStateReducer
    * where the return type of the reducers are different and needs to be a Generic StateType
    * eg. ReState -> StateType
 
 */
public func SimplifyReducer<T>(_ reducer: @escaping StateReducer<T>) -> ReStateReducer where T : StateType {
    return { (action, state) -> StateType? in
        return reducer(action, state as? T)
    }
}
