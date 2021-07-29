//
//  NavigationStateProtocol.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ReSwift

/**
 * protocol used for implementing identifier to the state
 */
public protocol Stringable {
    var string : String { get }
}

extension String : Stringable {
    public var string: String {
        return self
    }
}


/**
 protocol for implementing route navigation on StateTypes
 */
public protocol NavigationStateProtocol : StateType{
    
    ///contains the current route
    var routes : StatePropertyList<Stringable> {get}
    
    ///function for adding new route to its routes
    func push(routeName: String)
    
    ///function for removing the current route from its routes
    func pop()
    
}//NavigationStateProtocol

extension NavigationStateProtocol {
    
    public func push(routeName: String)  {
        self.routes.addElement(value: routeName)
    }
    
    public func  pop() {
        if self.routes.count > 0{
            _ = self.routes.removeElement(index: self.routes.count - 1)
        }
    }
}

public struct NavigationActionPush : Action {
    public var routeName: String
    public var navigationId : String
    
    public init(routeName: String, navigationId : String) {
        self.routeName      = routeName
        self.navigationId   = navigationId
    }
}

public struct NavigationActionPop : Action {
    public var navigationId : String
    
    public init(navigationId : String) {
        self.navigationId = navigationId
    }
}

/**
 State Reducer that resolves NavigationActions : eg. NavigationActionPop, NavigaitonActionPush

 parameters:
    - navId - Identification of the StateType that uses it
 */
public func navigationReducer<T>(navId: String) -> (Action, T?) -> T where T : NavigationStateProtocol{
    
    return { (action: Action, state: T?) -> T in
        guard  let state = state else {
            fatalError("State is Null")
        }
        
        switch action {
            
        case let push as NavigationActionPush:
            if navId == push.navigationId {
                state.push(routeName: push.routeName)
            }
            
        case let pop as NavigationActionPop:
            if navId == pop.navigationId {
                state.pop()
            }
            
        default:
            break
        }
        
        return state
    }
    
}//navigationReducer


/**
 State Reducer that resolves NavigationActions : eg. NavigationActionPop, NavigaitonActionPush
 
 ATTENTION:
    - used for subreducer where the substates are optional
 
 parameters:
 - navId - Identification of the StateType that uses it
 */
public func navigationSubReducer<T>(navId: String) -> (Action, T?) -> T? where T : NavigationStateProtocol{
    
    return { (action: Action, state: T?) -> T? in
        guard  let state = state else {
            return nil
        }
        
        switch action {
            
        case let push as NavigationActionPush:
            if navId == push.navigationId {
                state.push(routeName: push.routeName)
            }
            
        case let pop as NavigationActionPop:
            if navId == pop.navigationId {
                state.pop()
            }
            
        default:
            break
        }
        
        return state
    }
    
}//navigationReducer




