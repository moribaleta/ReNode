//
//  SVGNode.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import AsyncDisplayKit
import SVGgh

public class SVGNode : ResizeableNode {
    //let sview = SVGDocumentView.init()
    
    public var sview : SVGDocumentView? {
        return self.view as? SVGDocumentView
    }
    
    public override init() {
        super.init()
        /*
        self.setViewBlock {
            [weak self] () -> UIView in
            return (self?.sview ?? UIView())
        }
        */
        self.setViewBlock { () -> UIView in
            return SVGDocumentView.init()
        }
    }
    
    /*
    deinit {
        self.view.removeAllSubviews()
    }
    */
    
    public convenience init(assetName: String, bundle: Bundle) {
        self.init()
        sview?.renderer = SVGRenderer(dataAssetNamed: assetName, with: bundle)
    }
    
    public func set(assetName: String, bundle: Bundle) {
        sview?.renderer = SVGRenderer(dataAssetNamed: assetName, with: bundle)
    }
}

