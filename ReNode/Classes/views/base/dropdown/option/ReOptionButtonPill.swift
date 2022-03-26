//
//  ReOptionButtonPill.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift


public final class ReOptionButtonPill : ReDropdownBase<ReOptionActionItem> {
    
    var selectButton : ReButton!

    
    public override init() {
        super.init()
        
        self.selectButton = ReButton.create(
            text: "SELECT ▼",
            config: .ROUND_BLACK
        )
    }
    
    public override func didLoad() {
        super.didLoad()
        
        self.renderEntryCell = ReOptionButtonEntry.CREATE
        
        self.selectButton
            .rxTap
            .bind { [unowned self] in
                self.onShowDropdown()
            }
            .disposed(by: self.disposeBag)
        
        self.emitSelection
            .rx
            .distinctUntilChanged()
            .bind { option in
                self.selectButton
                    .set(text: "\(option?.title ?? "SELECT") ▼",
                         config: .ROUND_BLACK)
            }.disposed(by: self.disposeBag)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec {
            self.selectButton
                .frame(
                    minWidth: 80
                )
        }
    }
}

/*public struct ReOptionButtonPillProps {
    var options     : [ReOptionActionItem]
    var selected    : ReOptionActionItem?
}

open class ReOptionButtonPill : ReactiveNode<ReOptionButtonPillProps> {
    
    var optionCustomNode : ReOptionButtonCustom!
    
    var title : String?
    
    public var selectedIndex : Int? {
        didSet{
            self.selected = self.options[self.selectedIndex ?? 0]
        }
    }
    
    public var placeholder : String = "SELECT"
    
    public var selected: ReOptionActionItem? {
        didSet {
            //self.optionButton.setTitle(text: "\(self.selected!.title) ▼", attributes: [.tiny, .pilledBlack])
            self.optionCustomNode.optionButton.set(text: "\(self.selected?.title ?? self.placeholder) ▼", config: .init(shape: .round, fontColor: .white, backgroundColor: .black))
            self.optionCustomNode.optionButton.contentEdgeInsets  = .init(horizontal: 5, vertical: 0)
            self.optionCustomNode.layer.opacity = 0.2
            UIView.animate(withDuration: 0.3) {
                self.optionButton.layer.opacity = 1
            }
        }
    }
    
    convenience init(title: String, placeholder: String? = nil) {
        self.init()
        self.title          = title
        self.placeholder    = placeholder ?? "SELECT"
    }
        
    open override func didLoad() {
        super.didLoad()
        
        self.optionButton.set(text: "\(self.title ?? self.placeholder) ▼", config: .init(shape: .round, fontColor: .white, backgroundColor: .black))
        self.optionButton.contentEdgeInsets  = .init(horizontal: 5, vertical: 0)
        self.optionButton.layer.opacity = 0.2
        UIView.animate(withDuration: 0.3) {
            self.optionButton.layer.opacity = 1
        }
        
        self.cornerRadius = 15
        
    }
    
    open override func reactiveBind(obx: Observable<ReOptionButtonPillProps>) {
        super.reactiveBind(obx: obx)
        self.optionButton.reactiveBind(obx: obx.map{
            $0.options
        })
    }
    
    open override func renderState(value: ReOptionButtonPillProps) {
        <#code#>
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec {
            self.optionButton
                .frame(
                    minWidth: 80

                )
        }
    }

}//ReOptionButtonPill
 */
