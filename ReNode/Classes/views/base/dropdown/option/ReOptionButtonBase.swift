//
//  ReOptionButton.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift

///base class to which option buttons can extend
open class ReOptionButtonBase<T> : ReactiveNode<[T]> where T : ReDropdownEntryType {
    
    public var optionButton     = ReButton()
    public var options          = [T]()
    
    public weak var dropdownPeg : UIViewController?
    
    public var emitSelection    : RePropRelay<T>!
    
    public var selectedIndex    : Int?
    
    public var rxOption : Observable<T> {
        return emitSelection.asObservable().unwrap()
    }
    
    var emitIndex = PublishSubject<Int?>()
    
    public var optionSize : CGSize?
    
    public override init() {
        super.init()
        self.optionButton.set(config: .MORE_HORIZONTAL)
        self.emitSelection = .init()
    }
    
    public var renderEntryCell  : CallBack.typeCall<T, ASCellNode>?
    
    open override func didLoad() {
        super.didLoad()
        
        
        let renderEntryCell : ((T, ASTableNode, ReCellProperties) -> ASCellNode) = {
            [weak self] element, _,_ -> ASCellNode in
            self?.renderEntryCell?(element) ?? ASCellNode()
        }
        
        self.optionButton
            .rxTap
            .bind(onNext: { [unowned self] in
                
                guard let presenter = self.dropdownPeg else {
                    print("dropdownPeg not provided")
                    return
                }
                
                ReDropdownPopover<T>
                    .prompt(presenter   : presenter,
                            peg         : self.view,
                            list        : self.props ?? [],
                            renderCell  : renderEntryCell
                    )
                    .bind (onNext: { [weak self] selection in
                        self?.emitSelection.accept(selection.item)
                    }).disposed(by: self.disposeBag)
                
            })
            .disposed(by: self.disposeBag)
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec {
            self.optionButton
        }
    }

}//ReOptionButtonBase


///display represent each option of the ReOpotionButtonBase
public final class ReOptionButtonEntry : ReCellNode {
    var icon    : ReTextNode?
    var title   : ReTextNode!
    
    public init(icon: Icon?, title: String) {
        super.init()
        
        if let icon = icon {
            self.icon = .init(attributes: {
                ReAttributedStringTraits.IconText(icon: icon, iconSize: 12)
            })
        }
        self.title = .init(title)
    }
    
    public static let CREATE : CallBack.typeCall<ReOptionIconTextType, ReOptionButtonEntry> = {
        ReOptionButtonEntry(icon: $0.icon, title: $0.string)
    }
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASLayoutSpec
            .hStackSpec {
                if let icon = icon {
                    icon
                }
                self.title
            }
            .align(.center)
            .insetSpec(10)
    }
    
}//ReOptionButtonEntry
