//
//  ViewController.swift
//  ReNodeSample
//
//  Created by Gabriel Mori Baleta on 8/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ReNode
import AsyncDisplayKit

class ViewController: ASDKViewController<UIMain> {

    class func spawn() -> ViewController {
        return .init(node: .init())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = ReTextNode("Help me")
    }


}

struct Props {
    
}


class UIMain : ReNode<Props>{
    
    override init() {
        super.init()
        backgroundColor = .white
    }
    
}

