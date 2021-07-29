//
//  ReCollection.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import UIKit

/**
 UI component that implements table used for rendering a single state property in a table
 ATTENTION:
    * if you are using a single list use singleListBind() use sectionListBind() on multiple section
 */
open class ReCollection<E> : ASCollectionNode, ReProtocol, ASCollectionDataSource, ASCollectionDelegate {
    
    public typealias StateList = StatePropertyList<StatePropertyList<E>>
    
    private var reDisposeBag = DisposeBag()
    
    ///state property list contains all the items to be displayed
    open var tablelist : StatePropertyList<StatePropertyList<E>>?
    
    
    ///for returning the cell node to be used
    open var renderCell : ((E,ASCollectionNode, ReCellProperties) -> ASCellNode)?
    
    /// render view for section header
    open var renderHeader : ((Any?, ASTableNode) -> UIView)?
    
    /// an optional table delegate if you want to use your own function
    public weak var collectionDelegate : ASCollectionDelegate?
    
    ///publish subject for emitting the item selected and it's indexpath
    var emitSelect  = PublishSubject<(item : E, indexPath: IndexPath)>()
    
    ///subscriber for the selection in the table
    public var rxSelect    : Observable<(item : E, indexPath: IndexPath)> {
        return emitSelect
    }
    
    public var disposeBag   = DisposeBag()
    
    override open func didLoad() {
        super.didLoad()
        self.delegate   = self
        self.dataSource = self
        self.view.delaysContentTouches = false
        self.view.panGestureRecognizer.delaysTouchesBegan = false
        
        self.emitContentChanges
            .debounce(.milliseconds(5), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] in
                self?.onContentChanges()
            }).disposed(by: self.disposeBag)
        
        self.emitContentChanges.onNext(())
        
    }
    
    ///passes a single stateproperty list then maps it to a stateproperty list of sections to the table
    public func singleListBind(simple: Observable<StatePropertyList<E>>) {
        let obx = simple.map { simpleList -> StateList in
            let data = StateList([simpleList])
            data.isDirty = false
            data.appendChange(type: .change, index: 0, value: simpleList)
            return data
        }
        
        reBind(obx: obx)
    }
    
    ///passes a stateproperty list of sections to the table
    public func sectionListBind(obx: Observable<StateList>) {
        self.reBind(obx: obx)
    }
    
    public func sectionListBind(obx: Observable<StatePropertyList<StateSectionList<E>>>) {
        self.reBind(obx: obx.map{ (state) -> StatePropertyList<StatePropertyList<E>> in
            let sections = state.map { (section) -> StatePropertyList<E> in
                return section
            }
            let stateSections = StatePropertyList<StatePropertyList<E>>(sections)
            stateSections.isDirty = state.isDirty
            
            stateSections.changes = state.changes.map({ (action) -> StatePropertyAction<StatePropertyList<E>> in
                return StatePropertyAction<StatePropertyList<E>>.init(type: action.type, index: action.index, value: action.value!)
            })
            return stateSections
        })
    }
    
    public func reBind(obx: Observable<StateList>) {
        
        reDisposeBag = DisposeBag()
        
        obx.take(1)
            .subscribe(onNext: { [weak self] emission in
                self?.renderState(value: emission)
            })
            .disposed(by: reDisposeBag)
        
        obx.skip(1)
            .subscribe(onNext: { [weak self] emission in
                self?.reUpdate(value: emission)
            })
            .disposed(by: reDisposeBag)
    }
    
    open func reUpdate(value: StateList) {
        
        self.tablelist = value
        if value.isDirty {
            self.reloadData()
        } else if value.hasChanges {
            self.applySectionChange(changes: value.changes)
        } else{
            value.list.enumerated().forEach { (index, section) in
                self.reloadSection(section: section, sectionIndex: index)
            }
        }
        
    }
    
    open func renderState(value: StateList) {
        
        self.tablelist = value
        self.reloadData()
    }

    
    /// apply changes on a section level
    public func applySectionChange(changes: [StatePropertyAction<StatePropertyList<E>>]) {
        
        for change in changes {
            
            // let indexPath = IndexPath(row: change.index, section: 0)
            let indexSet = IndexSet.init(integer: change.index)
            
            switch change.type {
            case .add :
                self.insertSections(indexSet)
            case .change:
                if change.rerender {
                    self.reloadSection(section: self.tablelist!.get(index: change.index)!, sectionIndex: change.index)
                }
            case .remove:
                self.deleteSections(indexSet)
            }
        }
    }//applySectionChange
    
    public func reloadSection(section: StatePropertyList<E>, sectionIndex: Int) {
        if section.isDirty {
            
            let indexSet = IndexSet.init(integer: sectionIndex)
            self.reloadSections(indexSet)
        } else if section.hasChanges {
            self.applyChange(section.changes, sectionIndex: sectionIndex)
        }
    }//reloadSection
    
    
    ///applies the changes from the changes in state propertylist
    public func applyChange(_ changes: [StatePropertyAction<E>], sectionIndex: Int) {
        
        performBatchUpdates({
            for change in changes {
                
                let indexPath = IndexPath(row: change.index, section: sectionIndex)
                
                if (sectionIndex < self.tablelist?.count ?? 0) && (change.index < self.tablelist?[sectionIndex]?.count ?? 0 ) {
                    switch change.type {
                    case .add :
                        //self.insertRows(at: [ indexPath ])
                        self.insertItems(at: [indexPath])
                    case .change:
                        if change.rerender {
                            print("sample change rerender: \(indexPath)")
                            self.reloadItems(at: [indexPath])
                            //self.reloadRows(at: [ indexPath ])
                        }
                    case .remove:
                        self.deleteItems(at: [indexPath])
                        //self.deleteRows(at: [ indexPath ])
                    }
                } else {
                    print("am i a joke to you?")
                }
            }
        }, completion: nil)
        
        
    }//applyChange
    

    open func numberOfSections(in tableNode: ASTableNode) -> Int {
        return self.tablelist?.count ?? 0
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        let count = self.tablelist?.get(index: section)?.count ?? 0
        return count//self.tablelist?.get(index: section)?.count ?? 0
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        if let item = self.tablelist?.get(index: indexPath.section)?.get(index: indexPath.row) {
            return self.renderCell?(item, collectionNode, ReCellProperties(indexPath: indexPath, searchTerm: nil, isSelected: false)) ?? ASCellNode()
        }
        return ASCellNode()
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        self.deselectItem(at: indexPath, animated: true)
        
        if let item = self.tablelist?.get(index: indexPath.section)?.get(index: indexPath.row) {
            self.emitSelect.onNext((item: item, indexPath: indexPath))
        }
        
        self.collectionDelegate?.collectionNode?(collectionNode, didSelectItemAt: indexPath)
    }
    
    public var isBatchEnable = false
    
    public var rxOnReachEnd : Observable<Void>{
        return emitReachEnd
    }
    
    var emitReachEnd = PublishSubject<Void>()
    
    public var shouldTableBatchFetch : ((ASTableNode) -> Bool)?
    
    open var loading : ((ASTableNode) -> Bool)?
    
    public func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        let willFetch = isBatchEnable ? self.shouldTableBatchFetch?(tableNode) ?? false : false
        return willFetch
    }
    
    public func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        if !(self.loading?(tableNode) ?? false) {
            self.emitReachEnd.onNext(())
        }
        context.completeBatchFetching(true)
    }
    
    public var lastContentOffset: CGFloat = 0

    // MARK: dont add private this will not be called if doing so
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
        if scrollEmitEnabled {
            self.emitOnScroll.onNext(lastContentOffset)
        }
    }

    // MARK: dont add private this will not be called if doing so
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
        if scrollEmitEnabled {
            self.emitOnScroll.onNext(lastContentOffset)
        }
        
    }
    
    
    public var rxScroll     : Observable<CGFloat> {
        return emitOnScroll.asObservable()
    }
    
    public var rxScrollContent: Observable<CGPoint> {
        return emitOnScrollContent.asObservable()
    }
    
    public var automaticallyDisableScrollOnContentSize: Bool = true
    
    public var emitOnScroll = PublishSubject<CGFloat>()
    
    public var emitOnScrollContent: PublishSubject<CGPoint> = .init()
    
    public var scrollEmitEnabled = true
    
    ///used to determine if the scroll height should enable display scroll emit
    public var automaticScrollHeightContentEmit = true
    
    public var scrollOffsetThreshold    : CGFloat = 0
    
    public var emitContentChanges       = BehaviorSubject<Void>(value: ())
    
    open override func layoutDidFinish() {
        super.layoutDidFinish()
        self.emitContentChanges.onNext(())
    }
}//SimpleRxTable


extension ReCollection : ReScrollNodeType {
    
    public func onContentChanges() {
        guard automaticScrollHeightContentEmit else {
            return
        }
        
        
        let viewSize    = self.view.frame.height
        let contentSize = self.view.contentSize.height
        if contentSize < viewSize + self.scrollOffsetThreshold {
            self.scrollEmitEnabled  = false
        } else {
            self.scrollEmitEnabled  = true
        }
        
        self.view.isScrollEnabled   = self.automaticallyDisableScrollOnContentSize ? self.scrollEmitEnabled : true
    }
    
}

