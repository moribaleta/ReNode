//
//  Reactive.swift
//  ReNode
//
//  Created by Mini on 3/22/22.
//

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit

//DEPRECATED:
/*extension Reactive where Base: ASControlNode {
    func controlEvent(_ event: ASControlNodeEvent) -> Driver<ASControlNode> {
        Observable<ASControlNode>.create { obx in

            let holder = EventHolder(target: base, obx: obx, event: event)
            
            return Disposables.create {
                holder.release()
            }
        }.asDriver(onErrorRecover: { _ in Driver.never() })
    }
}*/
