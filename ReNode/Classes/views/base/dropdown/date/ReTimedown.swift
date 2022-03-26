//
//  ReTimedown.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/23/22.
//

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit

/**
 * view component shows the date and shows the popup to update it
 */
open class ReTimedown           : ReDatedown {
    
    private var emitDate        = BehaviorRelay<Date?>(value: nil)
    
    public convenience init(
        placeholder : String?           = nil,
        date        : Date?             = nil,
        dropdownPeg : UIViewController? = nil,
        isClearable : Bool              = false
    ) {
        self.init()
        self.placeholder        = placeholder
        self.textNode           = .init()
        
        self.placeholderNode    = .init(placeholder ?? "", attribute: .placeholder)
        self.date               = date
        self.isClearable        = isClearable
        self.border(radius: Common.text_corner_radius)
        
        self.tappableNode       = tell(.init()) {
            $0?.layoutContent = {
                [weak self] size -> ASLayoutSpec in
                self?.layoutContent() ?? .init()
            }
        }
        
        self.iconNode           = tell(.init()){
            $0?.attributedText = Common.textBuild{
                ReAttributedStringTraits.IconText(icon: .utilTime)
            }
        }
    }
    
    open override func didLoad() {
        super.didLoad()
        
        self.textNode
            .textContainerInset = .topInset(5)
        self.placeholderNode
            .textContainerInset = .topInset(5)
        
        self.tappableNode
            .rxTap
            .bind(onNext: {
                [unowned self] in
                guard let refVC = self.dropdownPeg else {
                    print("No View Controller provided")
                    return
                }
                ReDatedownPopover.prompt(
                    self.props?.unsafelyUnwrapped,
                    refVC           : refVC,
                    peg             : self.view,
                    isClearable     :  self.isClearable,
                    datePickerMode  : .time
                )
                    .bind {
                        [weak self] in
                        self?.emitDate.accept($0)
                        self?.renderState(value: $0)
                    }.disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
    }
    

}//ReDatedown
