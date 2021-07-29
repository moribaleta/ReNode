//
//  ReSingleTable.swift
//  SMDModuleDashboard
//
//  Created by Gabriel on 23/09/2019.
//  Copyright © 2019 LeapFroggr Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa


public protocol ReTableItem: AnyObject {
    var lifetime: PublishSubject<Void> { get set }
}


/**
 UI component that implements table used for rendering a single state property in a table
 ATTENTION:
 * if you are using a single list use singleListBind() use sectionListBind() on multiple section
 */
open class ReTable<E> : ASTableNode, ReProtocol, ASTableDataSource, ASTableDelegate, ReScrollNodeType {
    
    
    
    public var automaticallyDisableScrollOnContentSize: Bool = true
    
    public var rxScrollContent: Observable<CGPoint> {
        return emitOnScrollContent.asObservable()
    }
    
    public var emitOnScrollContent: PublishSubject<CGPoint> = .init()
    
    
    public typealias StateList = StatePropertyList<StatePropertyList<E>>
    
    private var reDisposeBag = DisposeBag()
    
    ///state property list contains all the items to be displayed
    open var tablelist      : StatePropertyList<StatePropertyList<E>>?
    
    
    ///for returning the cell node to be used
    open var renderCell     : ((E,ASTableNode, ReCellProperties) -> ASCellNode)?
    
    /// render view for section header
    open var renderHeader   : ((Any?, ASTableNode) -> UIView)?
    
    /// render view for section footer
    open var renderFooter   : ((Any?, ASTableNode) -> UIView)?
    
    /// height of the header
    open var headerHeight   : CGFloat = 30
    
    /// height of the footer
    open var footerHeight   : CGFloat = 30
    
    open var canMove        : ((IndexPath) -> Bool) = { (indexPath: IndexPath) -> Bool in return true }
    
    public var automaticallyHideEmptySection = false
    
    /// an optional table delegate if you want to use your own function
    public weak var tableDelegate : ASTableDelegate?
    
    ///used to determine if the scroll height should enable display scroll emit
    public var automaticScrollHeightContentEmit = true
    
    ///publish subject for emitting the item selected and it's indexpath
    var emitSelect  = PublishSubject<(item : E, indexPath: IndexPath)>()
    
    public var scrollEmitEnabled = true
    
    public var scrollOffsetThreshold    : CGFloat = 0
    
    public var emitContentChanges       = BehaviorSubject<Void>(value: ())
    
    public var disposeBag               = DisposeBag()
    
    
    public var debug = ""
    
    ///subscriber for the selection in the table
    public var rxSelect    : Observable<(item : E, indexPath: IndexPath)> {
        return emitSelect
    }
    
    override open func didLoad() {
        super.didLoad()
        self.delegate   = self
        self.dataSource = self
        self.view.delaysContentTouches = false
        self.view.panGestureRecognizer.delaysTouchesBegan = false
        
        self.leadingScreensForBatching = 0.2
        
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
    
    open func reBind(obx: Observable<StateList>) {
        
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
    
    @available(*, deprecated, message: "not used by reTable")
    public func reactiveBind(obx: Observable<StatePropertyList<StatePropertyList<E>>>) {
        
    }
    
    @available(*, deprecated, message: "not used by reTable")
    public func reactiveUpdate(value: StatePropertyList<StatePropertyList<E>>) {
        
    }
    
    open func reUpdate(value: StateList) {
        
        self.tablelist = value
        
        if value.isDirty {
            if debug.isEmpty == false { print("table.\(debug): isDirty renderState") }
            self.renderState(value: value)
        } else if value.hasChanges {
            if debug.isEmpty == false { print("table.\(debug): hasChanges") }
            self.applySectionChange(changes: value.changes)
        } else{
            if debug.isEmpty == false { print("table.\(debug): else") }
            value.list.enumerated().forEach { (index, section) in
                self.reloadSection(section: section, sectionIndex: index)
            }
        }
        self.emitContentChanges.onNext(())
    }
    
    open func renderState(value: StateList) {
        self.tablelist = value
        self.currsection_count = value.count
        self.reloadData()
        self.emitContentChanges.onNext(())
    }
    
    ///called after update or render is finished  - determines if scroll event should emit or not to prevent stuttering on scroll if the cell is one or too small
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
    
    open override func layoutDidFinish() {
        super.layoutDidFinish()
        self.emitContentChanges.onNext(())
    }
    
    
    /// apply changes on a section level
    open func applySectionChange(changes: [StatePropertyAction<StatePropertyList<E>>]) {
        
        for change in changes {
            
            // let indexPath = IndexPath(row: change.index, section: 0)
            let indexSet = IndexSet.init(integer: change.index)
            
            switch change.type {
            case .add :
                self.currsection_count += 1
                self.insertSections(indexSet, with: .automatic)
            case .change:
                if change.rerender {
                    self.reloadSection(section: self.tablelist!.get(index: change.index)!, sectionIndex: change.index)
                }
            case .remove:
                self.currsection_count -= self.currsection_count > 0 ? 1 : 0
                self.deleteSections(indexSet, with: .automatic)
            }
        }
    }//applySectionChange
    
    
// FOR REFERENCE PLS DONT REMOVE - interferes with scrolldidviewtop - commented
//    public func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
//        if let lifecyledNode = node as? ReTableItem {
//            // conforming classes to this protocol will be let known that that specific cell
//            // has been hidden, thus any events tied to that view should be disposed.
//            // use `take(until:)` on your item subscriptions to use this effectively.
//            lifecyledNode.lifetime.onNext(())
//        }
//    }
    
    public func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
        if let lifecyledNode = node as? ReTableItem {
            // conforming classes to this protocol will be let known that that specific cell
            // has been hidden, thus any events tied to that view should be disposed.
            // use `take(until:)` on your item subscriptions to use this effectively.
            lifecyledNode.lifetime.onNext(())
        }
    }

    
    /// reloads the section if dirty else apply changes on the section's list
    open func reloadSection(section: StatePropertyList<E>, sectionIndex: Int) {
        if section.isDirty || isFirstLastRowRemove(section.changes, sectionIndex: sectionIndex){ //if the changes has delete it's safer to delete the row
            let indexSet    = IndexSet.init(integer: sectionIndex)
            self.reloadSections(indexSet, with: .automatic)
        } else if section.hasChanges {
            self.applyChange(section.changes, sectionIndex: sectionIndex)
        }
    }//reloadSection
    
    
    ///applies the changes from the changes in state propertylist
    open func applyChange(_ changes: [StatePropertyAction<E>], sectionIndex: Int) {
        
        performBatchUpdates({
            for change in changes {
                
                let indexPath = IndexPath(row: change.index, section: sectionIndex)
                
                if (sectionIndex < self.tablelist?.count ?? 0) && (change.index < self.tablelist?[sectionIndex]?.count ?? 0 ) {
                    switch change.type {
                    case .add :
                        self.insertRows(at: [ indexPath ], with: .automatic)
                    case .change:
                        if change.rerender {
                            print("sample change rerender: \(indexPath)")
                            
                            self.reloadRows(at: [ indexPath ], with: .automatic)
                        }
                    case .remove:
                        self.deleteRows(at: [ indexPath ], with: .automatic)
                    }
                } else {
                    print("am i a joke to you?")
                }
            }
        }, completion: nil)
        
        
    }//applyChange
    
    ///checks if the changes have remove at the first or last row
    open func isFirstLastRowRemove(_ changes: [StatePropertyAction<E>], sectionIndex: Int) -> Bool {
        return changes.contains(where: {$0.type == .remove && ($0.index == self.tablelist![sectionIndex]!.count || $0.index == 0)})
    }
    
    public var currsection_count = 0
    
    open func numberOfSections(in tableNode: ASTableNode) -> Int {
        //return self.tablelist?.count ?? 0
        return self.currsection_count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.tablelist?.get(index: section)?.count ?? 0
        return count//self.tablelist?.get(index: section)?.count ?? 0
    }
    
    open func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if let item = self.tablelist?.get(index: indexPath.section)?.get(index: indexPath.row) {
            return self.renderCell?(item, tableNode, ReCellProperties(indexPath: indexPath, searchTerm: nil, isSelected: false)) ?? ASCellNode()
        }
        return ASCellNode()
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.automaticallyHideEmptySection {
            return renderHeader == nil || (self.tablelist?[section]?.isEmpty ?? true) ? 0 : self.headerHeight
        }
        return renderHeader == nil ? 0 : self.headerHeight
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.automaticallyHideEmptySection && (self.tablelist?[section]?.isEmpty ?? true) {
            return nil
        } else {
            let sectionItem : Any? = (self.tablelist?[section] as? StateSectionList<E>)?.sectionItem
            return renderHeader?(sectionItem, self)
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return renderFooter == nil ? 0 : self.footerHeight
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionItem : Any? = (self.tablelist?[section] as? StateSectionList<E>)?.sectionItem
        return renderFooter?(sectionItem, self)
    }
    
    open func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        self.deselectRow(at: indexPath, animated: true)
        if let item = self.tablelist?.get(index: indexPath.section)?.get(index: indexPath.row) {
            self.emitSelect.onNext((item: item, indexPath: indexPath))
        }
        
        self.tableDelegate?.tableNode?(tableNode, didSelectRowAt: indexPath)
    }
    
    public var isBatchEnable = false
    
    public var rxOnReachEnd : Observable<Void>{
        return emitReachEnd.asObservable()
    }
    
    var emitReachEnd = PublishSubject<Void>()
    
    public var shouldTableBatchFetch : ((ASTableNode) -> Bool)?
    
    open var loading : ((ASTableNode) -> Bool)?

    
    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return canMove(indexPath)
    }
    
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let element = self.tablelist?.list[sourceIndexPath.section].list[sourceIndexPath.row] else {
            return
        }
        
        tablelist?.list[sourceIndexPath.section].list.remove(at: sourceIndexPath.row)
        tablelist?.list[sourceIndexPath.section].list.insert(element, at: destinationIndexPath.row)
    }
    
    public var rxScroll     : Observable<CGFloat> {
        return emitOnScroll.asObservable()
    }
    
    public var emitOnScroll        = PublishSubject<CGFloat>()
    
    public var lastContentOffset   : CGFloat = 0

    
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
        if scrollEmitEnabled {
            self.emitOnScroll.onNext(lastContentOffset)
        }
    }
    
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
        if scrollEmitEnabled {
            self.emitOnScroll.onNext(lastContentOffset)
        }
        
        if isBatchEnable ? self.shouldTableBatchFetch?(self) ?? false : false {
            let offsetY = scrollView.contentOffset.y + 50
            let contentHeight = scrollView.contentSize.height
            
            if offsetY > contentHeight - scrollView.frame.size.height {
                if !(self.loading?(self) ?? false) {
                    self.emitReachEnd.onNext(())
                }
            }
        }
    }
    
    /*
     func onDidScroll(point: CGPoint){
     self.lastContentOffset = point.y
     if scrollEmitEnabled {
     self.emitOnScroll.onNext(lastContentOffset)
     }
     
     if isBatchEnable ? self.shouldTableBatchFetch?(self) ?? false : false {
     let offsetY = point.y + 50
     let contentHeight = self.view.contentSize.height
     
     if offsetY > contentHeight - self.view.frame.size.height {
     if !(self.loading?(self) ?? false) {
     self.emitReachEnd.onNext(())
     }
     }
     }
     }
     */
    
    
    
    
}//SimpleRxTable

public extension ReTable {
    
    var rowsCount: Int {
        let sections = self.numberOfSections
        var rows = 0
        
        for i in 0...sections - 1 {
            rows += self.numberOfRows(inSection: i)
        }
        
        return rows
    }
    
    func scrollToBottom() {
        
        var indexPath : IndexPath?
        
        guard self.numberOfSections - 1 > 0 else {return}
        
        for i in 0 ... self.numberOfSections - 1 {
            let rows = self.numberOfRows(inSection: i)
            if rows > 0 {
                indexPath = .init(row: rows - 1, section: i)
            }
        }
        if let indexPath = indexPath {
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
}

///class containing utility function for ReSingleTable
open class ReSingleTableUtilities {
    
    public class func DefaultHeader(item: Any?, table: ASTableNode) -> UIView {
        if let item = item as? String {
            let label = UILabel()
            label.attributedText = NSAttributedString(string: item)
            label.backgroundColor = .white
            return label
        }
        return UIView()
    }
    
    
}



///properties for each cell of the table in ReSingleTable
public struct ReCellProperties {
    
    ///contains the indexpath of the cell
    public var indexPath : IndexPath
    
    ///contains the search entry to be highlighted
    public var searchTerm : String?
    
    ///used for selectable cell
    public var isSelected : Bool = false
}

