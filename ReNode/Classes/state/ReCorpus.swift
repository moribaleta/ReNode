//
//  ReCorpus.swift
//  
//
//  Created by Gabriel Mori Baleta on 8/4/21.
//

import Foundation
import ReSwift
import ReSwiftThunk

public extension Store {
    
    ///accepts ReCorpus actions
    func dispatchReThunk<T> (_ action: T) where T : ReCorpus {
        self.dispatch(action.bodybuilder())
    }
    
}

/**
 * basic definition of ReCorpus
 */
public protocol ReCorpusBase : Action {
    var  name   : String {get}
}

/**
 * protocol implements thunk operation
 */
public protocol ReCorpus : ReCorpusBase {
    
    associatedtype State : StateType
    
    func body(_ dispatchbody: @escaping DispatchBody) -> Thunk<State>
    func bodybuilder() -> Thunk<State>
    func execute(dispatch: @escaping DispatchFunction, getState: () -> State?) -> Void
}


public extension ReCorpus {
    
    typealias DispatchBody = (@escaping  DispatchFunction, () -> State?) -> ()
    
    var name: String {
        return String(describing: self)
    }
    
    func body(_ dispatchbody: @escaping DispatchBody) -> Thunk<State> {
        Thunk{
            dispatch, getstate in
            dispatchbody(dispatch, getstate)
        }
    }
    
    func bodybuilder() -> Thunk<State> {
        return self.body(self.execute)
    }

}
