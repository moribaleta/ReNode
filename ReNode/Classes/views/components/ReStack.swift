//
//  ReStack.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift


/**
 ui component for displaying a list of display in a vertical stackview
 */
open class ReStack<E> : ReactiveNode<StatePropertyList<E>>, ReEmptyState {
    
    public typealias StateList = StatePropertyList<E>
    
    ///defines the row spacing - default is 10
    public var rowSpacing : CGFloat = 10
    
    ///contains all the display being displayed in the stack
    public var children    = [ASDisplayNode]()
    
    ///for returning the ui to be displayed
    public var renderCell  : ((E,IndexPath) -> ASDisplayNode)?
    
    public var renderEmptyView: (() -> ASDisplayNode)?
    
    public var defaultEmptyView: ASDisplayNode = .init() //SULEmptyView()
    
    public var isEmpty: (() -> Bool)?
    
    public var isEmpty2 : ((StateList) -> Bool)?
    
    /** used to determine the direction of the stack eg vertical, horizontal stack */
    public var stackDirection : ASStackLayoutDirection = .vertical
    
    public var _isEmpty: Bool = true {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    public var debug = ""
    
    open override func didLoad() {
        super.didLoad()
    }
    
    open override func reactiveUpdate(value: StateList) {
        let value_ = self.isEmpty?() ?? self.isEmpty2?(value)
        self._isEmpty = value_ ?? false
        
        if value.isDirty {
            if debug.isEmpty == false { print("stack.\(debug): isDirty") }
            self.reloadData(value: value)
        } else if value.hasChanges {
            if debug.isEmpty == false { print("stack.\(debug): hasChanges") }
            self.applyChange(value.changes)
        }
    }
    
    open override func renderState(value: StatePropertyList<E>) {
        let value_ = self.isEmpty?() ?? self.isEmpty2?(value)
        self._isEmpty = value_ ?? false
        
        self.reloadData(value: value)
    }
    
    ///reloads all the views from state propertylist
    open func reloadData(value: StateList){
        self.children = value.list.enumerated()
            .map({ return
                self.renderCell?($0.element, IndexPath(row: $0.offset, section: 0))
                    ?? ASDisplayNode()})
        
        self.setNeedsLayout()
        
    }//reloadData
    
    ///applies the changes from the changes in state propertylist
    open func applyChange(_ changes: [StatePropertyAction<E>]) {
        for change in changes {
            let indexPath = IndexPath(row: change.index, section: 0)
            
            switch change.type {
            case .add :
                
                let cell = self.renderCell?((change.value)!, indexPath)
                    ?? ASDisplayNode()
                self.children.insert(cell, at: indexPath.row)
            case .change:
                guard indexPath.row < self.children.count else {break}
                if change.rerender {
                    let cell = self.renderCell?((change.value)!, indexPath)
                        ?? ASDisplayNode()
                    self.children[indexPath.row] = cell
                }
            case .remove:
                guard indexPath.row < self.children.count else {break}
                self.children.remove(at: indexPath.row)
            }
        }
        self.setNeedsLayout()
        
    }//applyChange
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        /*var stack = ASStackLayoutSpec(direction: .vertical, spacing: self.rowSpacing, justifyContent: .start,
            alignItems: .stretch, children: self.children)
        
        if self.stackDirection == .horizontal {
            stack = ASStackLayoutSpec(direction: .horizontal, spacing: self.rowSpacing, justifyContent: .start,
                                      alignItems: .stretch, flexWrap: .wrap,
                                      alignContent: .start, lineSpacing: self.rowSpacing, children: self.children)
        }*/
        
        var stack = ASLayoutSpec
            .vStackSpec {
                self.children
            }
            .align()
            .spacing(self.rowSpacing)
        
        if self.stackDirection == .horizontal {
            stack = ASLayoutSpec
                .hStackSpec{
                    self.children
                }
                .align()
                .spacing(self.rowSpacing)
                .wrap()
                .alignContent(.start)
                .lineSpacing(self.rowSpacing)
        }
        
        
        if self._isEmpty {
            /*stack = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start,
            alignItems: .stretch, children: [self.renderEmptyView?() ?? self.defaultEmptyView])*/
            stack = ASLayoutSpec
                .vStackSpec{
                    self.renderEmptyView?() ?? self.defaultEmptyView
                }
                .align()
        }
        
        return stack
    }
    
}//ReStack
