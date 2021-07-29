//
//  ReScroll.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift

/**
 ASScrollNode with scrollview delegate
 - no need to set automaticallyManageSubnodes and Contentsize
 */
open class ReScrollNode : ASScrollNode, ReScrollNodeType, UIScrollViewDelegate {

    public var rxScroll     : Observable<CGFloat> {
        return emitOnScroll.asObservable()
    }
    
    public var rxScrollContent : Observable<CGPoint> {
        return self.emitOnScrollContent.asObservable()
    }
    
    public var emitOnScroll         = PublishSubject<CGFloat>()
    
    public var emitOnScrollContent  = PublishSubject<CGPoint>()
    
    public var emitContentChanges   = BehaviorSubject<Void>(value: ())
    
    public var sizeClass    : UIUserInterfaceSizeClass? {
        return self.asyncTraitCollection().horizontalSizeClass
    }
    
    ///enables/disable scroll emission
    public var scrollEmitEnabled    = true
    
    public var scrollEnabled        = true
    
    ///used to determine if the scroll height should enable display scroll emit
    public var automaticScrollHeightContentEmit = true
    
    
    public var lastContentOffset        : CGFloat = 0
    
    ///threshold to be added on contentsize to determine if the view will be scrollable
    public var scrollOffsetThreshold    : CGFloat = 0
    
    public var automaticallyDisableScrollOnContentSize: Bool = true
    
    private var disposeBag = DisposeBag()
    
    ///called after update or render is finished  - determines if scroll event should emit or not to prevent stuttering on scroll if the cell is one or too small
    public func onContentChanges() {
        
        guard automaticScrollHeightContentEmit && (self.scrollableDirections == .down || self.scrollableDirections == .up) else {
            return
        }
        
        //table frame height doesn't update automatically
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        let viewSize    = self.view.frame.height
        let contentSize = self.view.contentSize.height
        if contentSize < viewSize + self.scrollOffsetThreshold {
            self.scrollEmitEnabled  = false
        } else {
            self.scrollEmitEnabled  = true
        }
        
        self.view.isScrollEnabled   = self.scrollEnabled ? (self.automaticallyDisableScrollOnContentSize ? self.scrollEmitEnabled : true) : false
        //}
    }
    
    public override init() {
        super.init()
        automaticallyManagesSubnodes    = true
        automaticallyManagesContentSize = true
        self.scrollableDirections       = .down
    }
    
    public func setContentOffset(_ point: CGPoint, animated: Bool) {
        self.view.setContentOffset(point, animated: animated)
    }
    
    
    
    open override func didLoad() {
        super.didLoad()
        self.view.delegate = self
        self.view.delaysContentTouches  = false
        self.view.canCancelContentTouches = true
        self.view.panGestureRecognizer.delaysTouchesBegan = self.view.delaysContentTouches;
        //self.onContentChanges()
        
        self.emitContentChanges
            .debounce(.milliseconds(2), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: {
            [unowned self] in
            self.onContentChanges()
        }).disposed(by: self.disposeBag)
        
        
        self.emitContentChanges.onNext(())
        
        self.view.rx.contentOffset.subscribe(onNext: {
            [unowned self] offset in
            self.lastContentOffset = offset.y
            if self.scrollEmitEnabled {
                self.emitOnScroll.onNext(self.lastContentOffset)
            }
        }).disposed(by: self.disposeBag)
        
        self.view.rx.didEndDecelerating.subscribe(onNext: {
            [unowned self] in
            if self.scrollEmitEnabled {
                self.emitOnScrollContent.onNext(self.view.contentOffset)
            }
        }).disposed(by: self.disposeBag)
    }
    
    open override func layoutDidFinish() {
        super.layoutDidFinish()
        //self.onContentChanges()
        self.emitContentChanges.onNext(())
    }
    
    open func scrollToBottom(){
        let bottomOffset = CGPoint(x: 0, y: self.view.contentSize.height - self.view.bounds.size.height)
        self.view.setContentOffset(bottomOffset, animated: true)
    }
    
    open func scrollToTop(){
        self.view.setContentOffset(.init(x: 0, y: 0), animated: true)
    }
    
}//ReScrollNode



public protocol ReScrollNodeType {
    
    
    var rxScroll        : Observable<CGFloat> {get}
    
    var rxScrollContent : Observable<CGPoint> {get}
    
    var emitOnScroll : PublishSubject<CGFloat>{get set}
    
    var emitOnScrollContent : PublishSubject<CGPoint>{get set}
    
    ///enables/disable scroll emission
    var scrollEmitEnabled   : Bool {get set}
    
    ///used to determine if the scroll height should enable display scroll emit
    var automaticScrollHeightContentEmit : Bool {get set}
    
    var lastContentOffset        : CGFloat {get set}
    
    var scrollOffsetThreshold    : CGFloat {get set}

    var automaticallyDisableScrollOnContentSize : Bool {get set}
    
    var emitContentChanges       : BehaviorSubject<Void>{get set}
    
    func onContentChanges()
}

public extension UIScrollView {
    
    ///scrolls to the bottom of the view
    func scrollToBottom(){
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: true)
    }

}

