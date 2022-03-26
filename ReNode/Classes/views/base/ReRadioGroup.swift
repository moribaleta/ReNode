//
//  ReRadioGroup.swift
//  ReNode
//
//  Created by Mini on 3/8/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift

open class ReRadioGroup : ResizeableNode {
    
    public var radios = [ReRadio]()
    
    public var previousSelectedIndex : Int?
    public var selectedIndex : Int? {
        didSet {
            if let prevIndex = previousSelectedIndex,
                prevIndex != selectedIndex {
                
                radios[prevIndex].isOn = false
            }
            
            if let currIndex = selectedIndex {
                radios[currIndex].isOn = true
            }
            
            self.previousSelectedIndex = self.selectedIndex
        }
    }
    public var values = [Stringable]() {
        didSet {
            didSetValues(values)
        }
    }
    
    public var axis : ASStackLayoutDirection = .vertical {
        didSet { setNeedsLayout() }
    }
    
    
    var emitIndex = PublishSubject<Int?>()
    public var rxIndex : Observable<Int?> {
        return emitIndex.asObservable()
    }
    
    override init() {
        super.init()
    }
    
    public convenience init(values: [Stringable]) {
        self.init()
        self.values = values
        self.didSetValues(values)
    }
    
    open override func didLoad() {
        super.didLoad()
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return ASStackLayoutSpec(direction: axis, spacing: 10, justifyContent: .start, alignItems: .start, children: radios)
    }
    
    
    private func didSetValues(_ values: [Stringable]) {
        radios = values.enumerated().map({ [unowned self] i, val in
            tell(ReRadio()) { [unowned self] radio -> Void in
                radio.object = val
                radio.rxTap.subscribe(onNext: { [unowned self]  tap  in
                    self.selectedIndex = i
                    self.emitIndex.onNext(i)
                }).disposed(by: radio.disposeBag)
            }
        })
        setNeedsLayout()
    }
}


