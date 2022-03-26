//
//  ReDropdown.swift
//  ReNode
//
//  Created by Mini on 2/24/22.
//

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit
import UIKit


open class ReDropdownBase<T>    : ReactiveNode<[T]> where T : ReDropdownEntryType {
    
    public var emitSelection    : RePropRelay<T>!
    
    public var rxSelection      : Observable<T?> {
        self.emitSelection.asObservable()
    }
    
    public var selection        : T? {
        get {
            self.emitSelection.value
        }
    }
    
    public var renderDisplay    : CallBack.typeCall<T?, ASDisplayNode>?
    public var renderEntryCell  : CallBack.typeCall<T, ASCellNode>?
    
    public weak var dropdownPeg : UIViewController?
    
    public var onSearch         : CallBack.typeCall<String?, [T]>? = nil
    
    public var dropdownItems    : [Stringable] = []
    public var placeholder      : String? = nil
    
    public override init() {
        super.init()
        
        self.emitSelection      = .init(value: nil)
    }
    
    /**
     * show dropdown
     */
    func onShowDropdown() {
        guard let presenter = self.dropdownPeg else {
            print("dropdownPeg not provided")
            return
        }
        
        let renderEntryCell : ((T, ASTableNode, ReCellProperties) -> ASCellNode) = {
            [weak self] element, _,_ -> ASCellNode in
            self?.renderEntryCell?(element) ?? ASCellNode()
        }
        
        ReDropdownPopover<T>
            .prompt(presenter   : presenter,
                    peg         : self.view,
                    list        : self.props ?? [],
                    onSearch    : self.onSearch,
                    renderCell  : renderEntryCell
            )
            .bind (onNext: { [weak self] selection in
                self?.emitSelection.accept(selection.item)
            }).disposed(by: self.disposeBag)
    }//onShowDropdown
    
    
    /**
     * reactive bind with a selector of finding the index
     * where the first variable is the array
     * and the last variable is the selected item
     */
    open func reactiveBind(obx: Observable<([T], T?)>) {
        self.reactiveBind(
            obx: obx.map{$0.0}
        )
        
        obx.map {
            $0.1
        }
        .distinctUntilChanged()
        .bind { [unowned self] selectedObject in
            guard let selectedObject = selectedObject else {
                self.emitSelection.accept(nil)
                return
            }
            
            self.setSelectedEntry { prop in
                return prop == selectedObject
            }
        }.disposed(by: self.reDisposeBag)
    }
    
    
    open override func renderState(value: [T]) {
        self.dropdownItems = value
    }//renderState
}


public extension ReDropdownBase {
    
    /**
     * setting the index based on the value compared to
     */
    @discardableResult func setSelectedEntry(where: (T) -> Bool) -> Int? {
        if let index = self.props?.firstIndex(where: `where`),let entry = self.props?[index] {
            self.emitSelection.accept(entry)
            return index
        } else {
            return nil
        }
    }
    
    /**
     * sets the entry based on the index given
     * - returns nil if the index doesnt exist from the selections
     */
    @discardableResult func setSelectedIndex(index: Int?) -> T? {
        guard let index = index,
              let entry = self.props?[index] else {
            return nil
        }
        self.emitSelection.accept(entry)
        return entry
    }
    
    
}

/**
 * base class to which all dropdown components should adhere to
 * provides convenience and template  in creating dropdowns
 */
open class ReDropdownNode<T>    : ReDropdownBase<T> where T : ReDropdownEntryType  {
    
    public var entryNode        : ASDisplayNode!
    public var iconNode         : ReTextNode!
    public var placeholderNode  : ReTextNode!
    public var tappableNode     : ReTappableNode!
    
    public override init() {
        super.init()
        
        self.placeholderNode    = .init()
        self.iconNode           = .init()
        self.entryNode          = .init()
        
        self.border(radius: Common.text_corner_radius)
        
        self.tappableNode       = tell(.init()) {
            $0?.layoutContent   = {
                [weak self] size -> ASLayoutSpec in
                self?.layoutContent() ?? .init()
            }
        }
        
        self.iconNode           = tell(.init()){
            $0?.attributedText  = Common.textBuild{
                ReAttributedStringTraits.IconText(icon: .arrowDown)
            }
        }
    }
    
    public convenience init(
        placeholder : String?           = nil,
        selection   : T?                = nil,
        dropdownPeg : UIViewController? = nil,
        isClearable : Bool              = false
    ) {
        self.init()
        self.relayoutOnPropsDidChange   = true
        self.placeholder                = placeholder
        self.entryNode                  = .init()
        self.placeholderNode            = .init(placeholder ?? "", attribute: .placeholder)
        
        self.emitSelection      = .init(value: selection)
    }
    
    open override func didLoad() {
        super.didLoad()
        
        self.placeholderNode.textContainerInset = .topInset(5)
        
        self.emitSelection
            .rx
            .bind(onNext: { [unowned self] val in
                //self.textNode.setText(val?.string ?? "")
                self.entryNode = self.renderDisplay?(val) ?? .init()
                self.tappableNode.setNeedsLayout()
                self.setNeedsLayout()
            })
            .disposed(by: self.disposeBag)
        
        self.tappableNode
            .rxTap
            .bind(onNext: { [unowned self] in
                self.onShowDropdown()
            })
            .disposed(by: self.disposeBag)
    }//didLoad
    
    
    
    open func layoutContent() -> ASLayoutSpec {
        ASLayoutSpec
            .hStackSpec {
                self.entryNode
                    .frame(minHeight: 30)
                    .overlaySpec {
                        if self.emitSelection.value != nil {
                            return ASSpacing()
                        } else {
                            return self.placeholderNode
                        }
                    }
                    .flex()
                self.iconNode
            }
            .align(.center)
            .insetSpec(horizontal: 10, vertical: 5)
    }//layoutContent
    
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec {
            self.tappableNode
        }
        .frame(minHeight: 40)
    }//layoutSpecThatFits
    

}//ReDropdown



