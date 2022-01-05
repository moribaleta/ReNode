//
//  SampleStore.swift
//  ReNodeSample
//
//  Created by Mini on 1/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ReNode

struct SampleCorpusStore : ReCorpus  {

    typealias State = SampleState
    
    func execute(dispatch: @escaping Dispatcher, getState: () -> SampleState?) {
        
    }
}
