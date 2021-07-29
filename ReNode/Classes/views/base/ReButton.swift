//
//  ReButton.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift

open class ReButton : ASButtonNode {
    
    public var rxTap : Observable<Void> {
        self.emitTap.asObservable()
    }
    
    fileprivate var emitTap = PublishSubject<Void>()
    
    open override func didLoad() {
        super.didLoad()
        self.addTarget(self, action: #selector(onTap), forControlEvents: .touchUpInside)
    }
    
    @objc private func onTap(sender: Any) {
        self.emitTap.onNext(())
    }
}
