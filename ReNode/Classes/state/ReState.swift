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
