//
//  ReDatedown.swift
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit

/**
 * view component shows the date and shows the popup to update it
 */
open class ReDatedown           : ReactiveNode<Date?> {
    
    private var emitDate        = BehaviorRelay<Date?>(value: nil)
    
    public var rxDate           : Observable<Date?> {
        self.emitDate.asObservable()
    }
    
    public var textNode         : ReTextNode!
    public var iconNode         : ReTextNode!
    public var placeholderNode  : ReTextNode!
    
    public var tappableNode     : ReTappableNode!
    
    public var placeholder      : String? = nil
    
    public weak var dropdownPeg : UIViewController?
    
    public var dateFormat       : DateFormatter!
    
    public var isClearable      : Bool = false
    
    public var date             : Date? {
        didSet {
            self.emitDate.accept(date)
        }
    }
    
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
                ReAttributedStringTraits.IconText(icon: .utilDate)
            }
        }
    }
    
    open override func didLoad() {
        super.didLoad()
        
        self.textNode.textContainerInset = .topInset(5)
        self.placeholderNode.textContainerInset = .topInset(5)
        
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
                    refVC       : refVC,
                    peg         : self.view,
                    isClearable :  self.isClearable
                )
                    .bind {
                        [weak self] in
                        self?.emitDate.accept($0)
                        self?.renderState(value: $0)
                    }.disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
    }

    
    open override func reactiveBind(obx: Observable<Date?>) {
        super.reactiveBind(obx: obx.distinctUntilChanged())
    }
    
    open override func renderState(value: Date?) {
        self.textNode.setText(value?.toLocalString(withFormat: .ShortRead) ?? "")
        self.emitDate.accept(value)
        self.setNeedsLayout()
        self.tappableNode.setNeedsLayout()
    }
    
    open func layoutContent() -> ASLayoutSpec {
        ASLayoutSpec
            .hStackSpec {
                self.textNode
                    .frame(minHeight: 30)
                    .overlaySpec {
                        if self.emitDate.value != nil {
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
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec {
            self.tappableNode
        }
        .frame(minHeight: 40)
    }

}//ReDatedown
