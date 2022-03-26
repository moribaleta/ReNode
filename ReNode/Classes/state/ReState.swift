//
//  ReState.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftThunk

/**
    protocal defines the base struct of StateType
 */
public protocol ReState : StateType {
    
    mutating func clearStateTypes()
    
}

public extension ReState {
    
    mutating func clearStateTypes() {
        let mirror = Mirror(reflecting: self)
        
        mirror.children.forEach { child in
            guard let clearable = child.value as? StateClearable else {
                return
            }
            clearable.clear()
        }
    }
    
    ///assuming the state has StateClearable they are all gonna be cleared
    static func clearStateTypes(state: Self) {
        let mirror = Mirror(reflecting: state)
        
        mirror.children.forEach { child in
            guard let clearable = child.value as? StateClearable else {
                return
            }
            clearable.clear()
        }
    }
    
}




