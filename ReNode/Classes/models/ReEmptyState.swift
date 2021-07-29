//
//  ReEmptyState.swift
//  SMDModuleUtility
//
//  Created by Gabriel on 25/09/2019.
//  Copyright © 2019 Leapfroggr Inc. All rights reserved.
//

import Foundation
import RxSwift
import AsyncDisplayKit

/**
 protocol for implementing Empty State on ASDisplayNode
 Note:
 * used for reactive component
 * add logic definition on the reactiveUpdate
 * renderEmptyView and defaultEmpty View should be added thru AddSubnode or set AutomaticallyManageSubnodes = true
 * renderEmptyView and defaultEmpty View should be added to the LayoutSpec to be viewed
 */
public protocol ReEmptyState {
    
    ///function for displaying the empty state
    var renderEmptyView : (() -> ASDisplayNode)? {get set}
    
    ///default view display for empty state
    var defaultEmptyView : ASDisplayNode {get set}
    
    ///function  for determining the empty state
    var isEmpty : (() -> Bool)? {get set}
    
    ///used to determine if the state is empty
    var _isEmpty : Bool {get set}
    
    func onPreviewEmpty() -> ASDisplayNode
    
}

extension ReEmptyState {
    
    public func onPreviewEmpty() -> ASDisplayNode {
        return self.renderEmptyView?() ?? self.defaultEmptyView
    }
    
}

