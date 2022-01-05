//
//  SampleState.swift
//  ReNodeSample
//
//  Created by Mini on 1/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ReNode

public struct SampleState : ReState {
    
    var list : StatePropertyList<String> = .init()
    var state_item : StateProperty<String> = .init(nil)
    var normal_item : String? = nil
    
    public mutating func clearStateTypes() {
        normal_item = nil
    }
    
}


