//
//  Reloader.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation
import AsyncDisplayKit

/**
 * ui view display shows a loading component
 * - should be instatiated in the main thread
 */
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
        self.loader.frame(equal: 48)
    }
    
    override func didLoad() {
        super.didLoad()
        self.indicator?.startAnimating()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.loader
            .centerSpec(.minimumXY, .XY)
    }
    
}//ReLoader
