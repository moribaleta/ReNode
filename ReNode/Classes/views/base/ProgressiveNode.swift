//
//  ProgressiveNode.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import AsyncDisplayKit

/**
 asdisplay node that the view is not yet loaded unless it is viewed from the screen
 - used for uiview with complex ui components
 */
open class ProgressiveNode : ResizeableNode, ProgressiveViewProtocol{
    
    ///loader component
    public lazy var loader          : ASDisplayNode? = ReLoader()
    
    ///used to determine if the view is visible from the screen
    public var isViewed             = false
    
    public var disposeBag           = DisposeBag()
    
    ///value used for timing the interval - default is 0.3 seconds
    public var interval_time        : RxTimeInterval = .milliseconds(300)
    
    public var layoutContentBlock   : ((ProgressiveNode, ASSizeRange) -> ASLayoutSpec)?
    
    public var rxLoaded             : Observable<Void> {
        return emitLoaded.asObservable()
    }
    private var emitLoaded          = PublishSubject<Void>()
    
    open override func didLoad() {
        super.didLoad()
        
        self.rxVisible(interval: self.interval_time)
            .filter { $0 }
            .take(1)
            .subscribe(onNext: { [unowned self] visible in
                self.isViewed = visible
                self.onDidViewVisible()
            }).disposed(by: disposeBag)
    }
    
    ///called when the view is visible
    open func onDidViewVisible(){
        self.setNeedsLayout()
        self.emitLoaded.onNext(())
    }
    
    ///display your contents here to be loaded progressively
    open func layoutContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.layoutContentBlock?(self, constrainedSize) ?? ASLayoutSpec()
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let content = self.layoutContent(constrainedSize)
        if !self.isViewed {
            return ASInsetLayoutSpec(insets: .init(all: 10), child: self.loader ?? ASDisplayNode())
        } else {
            return content
        }
    }
}

/**
 reactive node implementation of the ProgressiveViewProtocol doesnt load the view unless it is viewed from the screen
 - used for uiview with complex ui components
 */
open class ReProgressiveNode<T> : ReactiveNode<T>, ProgressiveViewProtocol {
    public var isViewed: Bool           = false
    
    public var loader: ASDisplayNode?   = ReLoader()
    
    public var interval_time            : RxTimeInterval = .milliseconds(300)
    
    public var rxLoaded                 : Observable<Void> {
        return emitLoaded.asObservable()
    }
    private var emitLoaded              = PublishSubject<Void>()
    
    public var layoutContentBlock       : ((ReProgressiveNode, ASSizeRange) -> ASLayoutSpec)?
    
    open override func didLoad() {
        super.didLoad()
        
        self.rxVisible(interval: self.interval_time)
            .filter { $0 }
            .take(1)
            .subscribe(onNext: { [unowned self] visible in
                self.isViewed = visible
                self.onDidViewVisible()
            }).disposed(by: disposeBag)
    }
    
    open func onDidViewVisible() {
        self.setNeedsLayout()
        self.emitLoaded.onNext(())
    }
    
    ///display your contents here to be loaded progressively
    open func layoutContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.layoutContentBlock?(self, constrainedSize) ?? ASLayoutSpec()
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let content = self.layoutContent(constrainedSize)
        if !self.isViewed {
            return ASInsetLayoutSpec(insets: .init(all: 10), child: self.loader ?? ASDisplayNode())
        } else {
            return content
        }
    }
}
