//
//  ReDropdownPopover.swift
//  ReNode
//
//  Created by Mini on 2/24/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift

class ReSlatItem {
    
    var name : String?
    var icon : String?
    var color : UIColor?
    var isEnabled : Bool?
}


public class ReDropdownPopover<T> : ASDKViewController<ASDisplayNode> where T : ReDropdownEntryType {
    /**
    present a popover containing an retable
     - parameter presenter: uiviewcontroller to present ReDropdownPopover
     - parameter peg: the uiview which the popup will be archored to
     - parameter list: this list to be show in the dropdown
     - parameter preferredSize: preferred size of popup can be optionally specified
     - parameter onSearch: func on filtering the dropdown list
     - parameter willSelect: filter func that gets called before selected row
     - parameter didSelect: func that gets called after row is being selected. by default, presenter will dismiss popover
     - parameter renderCell: func returning the table cell to be rendered in the popup
     - returns: observable of the cell being selected
     */
    static func prompt(
        presenter       : UIViewController,
        peg             : UIView,
        list            : [T],
        preferredSize   : CGSize? = nil,
        onSearch        : CallBack.typeCall<String?, [T]>? = nil,
        willSelect      : CallBack.typeCall<T, Bool>? = nil,
        didSelect       : CallBack.typeCall<(T, IndexPath, ASTableNode), Void>? = nil,
        renderCell      : ((T, ASTableNode, ReCellProperties) -> ASCellNode)? = nil
    ) -> Observable<(item : T, index: Int)> {
        
        let entryList = RePropRelay<[T]>(value: list)
        
        let table = tell(ReTable<T>()) {
            $0.singleListBind(
                simple: entryList.rx.map{.init($0 ?? [])}
            )
            $0.renderCell = renderCell ?? { element, table, props -> ASCellNode in
                let cell    = ASTextCellNode()
                cell.text   = element.string
                return cell
            }
            $0.view.separatorInset = .zero
        }
        
        let vc = tell(ReDropdownPopover(node: table)) {
            $0.preferredContentSize = preferredSize ?? .init(width: 300, height: 44 * list.count + (onSearch == nil ? 0 : 40))
            $0.willSelect = willSelect
            $0.didSelect = didSelect
        }
        
        if let onSearch = onSearch {
            
            let header = tell(ResizeableNode()) {
                header in
                
                let searchNode = tell(ASEditableTextNode()) {
                    $0.textView.rx.text
                        .bind (onNext: { string in
                            let entries = onSearch(string)
                            entryList.accept(entries)
                        })
                        .disposed(by: table.disposeBag)
                    
                    $0.textView.textContainerInset =
                        .topInset   (10)
                        .leftInset  (10)
                    
                    $0.border(radius: Common.text_corner_radius)
                }
                let clearNode  = tell(ReButton.create(icon: Icon.actionClose, config: .ICON30_CLEAR)) {
                    $0.rxTap
                        .bind (onNext: { _ in
                            searchNode.textView.text = ""
                        })
                        .disposed(by: table.disposeBag)
                }
                
                header.backgroundColor = .white
                
                entryList
                    .rx
                    .bind (onNext: { _ in
                        searchNode.becomeFirstResponder()
                    }).disposed(by: table.disposeBag)
                
                header
                    .layoutSpecBlock = {
                        _,_ in
                        ASLayoutSpec
                            .hStackSpec {
                                searchNode
                                .frame(maxHeight: 40)
                                .flex(grow: 1, shrink: 1)
                                clearNode
                            }
                            .align()
                            .insetSpec(horizontal: 10, vertical: 2)
                    }
            }
            
            if #available(iOS 15.0, *) {
                //table.view.tableNode?.view.sectionHeaderTopPadding = 0
                table.view.sectionHeaderTopPadding = 0
            }
            
            
            table.headerHeight = 40
            table.renderHeader = {
                _,_ in
                header.view
            }
        }
        
        presenter.presentPopup(vc: vc, peg: peg)
        return vc.rxSelection
    }
    
    
    var willSelect : CallBack.typeCall<T, Bool>?
    var didSelect : CallBack.typeCall<(T, IndexPath, ASTableNode), Void>?
    
    var rxSelection : Observable<(item : T, index: Int)> {
        return (self.node as! ReTable<T>).rxSelect
            .filter({ selection -> Bool in
                return self.willSelect?(selection.item) ?? true
            })
            .map { (item: $0.item, index: $0.indexPath.row) }
            .doNext{ [weak self] selection in
                if let didSelect = self?.didSelect {
                    didSelect((selection.item, IndexPath.init(row: selection.index, section: 0), self!.node as! ASTableNode))
                } else {
                    // default behavior is to dismiss the popover
                    self?.dismiss(animated: true)
                }
            }
    }
    
    
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        (self.node as? ReTable<T>)?.contentInset = self.view.safeAreaInsets
    }
}
