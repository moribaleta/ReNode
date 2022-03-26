//
//  Callback.swift
//  ReNode
//
//  Created by Mini on 2/21/22.
//

import Foundation

///class contains functional types
public final class CallBack {
    
    ///has a parameter and returns a void
    public typealias typeVoid<T>   = ((T)  -> Void)
    
    ///has no parameter and returns void
    public typealias void          = (()   -> Void)
    
    ///has no parameter and returns a value
    public typealias returnType<V> = ()    -> V
    
    ///has a parameter and returns a value
    public typealias typeCall<T,V> = (T)   -> V
    
    ///has a parameter of error and returns a void
    public typealias error         = (Error) -> Void
    
}//CallBack

