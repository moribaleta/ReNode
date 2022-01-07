//
//  SampleController.swift
//  ReNodeSample
//
//  Created by Mini on 1/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ReNode
import RxSwift

class SampleController : ReBaseController<SampleState, SampleState, SampleView> {
    
    class func spawn() -> SampleController {
        let node = SampleView()
        let vc = SampleController(node: node)
        return vc
    }
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ReNode Sample"
        
        ReactiveNode.table.rxSelect
            .subscribe(onNext: { selected in
                let vc : UIViewController = {
                    switch selected.indexPath.item {
                    case 0:  return VCSampleTexts.spawn()
                    case 1:  return VCSampleButtons.spawn()
                    default: return UIViewController()
                    }
                }()
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            }).disposed(by: disposeBag)
        
    }
}
