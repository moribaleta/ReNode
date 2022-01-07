//
//  SampleNavigation.swift
//  ReNodeSample
//
//  Created by Mini on 1/7/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class SampleNavigation : UINavigationController {
    
    static func spawn () -> SampleNavigation {
        return SampleNavigation.init(rootViewController: SampleController.spawn())
    }
}
