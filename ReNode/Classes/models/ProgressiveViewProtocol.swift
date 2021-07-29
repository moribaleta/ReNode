//
//  ProgressiveViewProtocol.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import AsyncDisplayKit

public protocol ProgressiveViewProtocol {
    
    var isViewed        : Bool {get set}
    var loader          : ASDisplayNode? {get set}
    var interval_time   : RxTimeInterval {get set}
    
    
    func onDidViewVisible()
    func layoutContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec
}


class ReLoader : ResizeableNode {
    
    var loader = ResizeableNode()
    
    var indicator : UIActivityIndicatorView? {
        self.loader.view as? UIActivityIndicatorView
    }
    
    override init() {
        super.init()
        self.loader.setViewBlock({
            UIActivityIndicatorView()
        })
        self.loader.style.height    = .init(unit: .points, value: 48)
        self.loader.style.width     = .init(unit: .points, value: 48)
    }
    
    override func didLoad() {
        super.didLoad()
        self.indicator?.startAnimating()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASCenterLayoutSpec(
            centeringOptions: .XY,
            sizingOptions   : .minimumXY,
            child           : self.loader)
    }
}
