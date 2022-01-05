//
//  SampleController.swift
//  ReNodeSample
//
//  Created by Mini on 1/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ReNode

class SampleController : ReBaseController<SampleState, SampleState, SampleView> {
    
    class func spawn() -> SampleController {
        let node = SampleView()
        let vc = SampleController(node: node)
        return vc
    }
    
}

