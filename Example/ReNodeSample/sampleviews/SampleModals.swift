//
//  SampleModals.swift
//  ReNodeSample
//
//  Created by Mini on 2/26/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ReNode
import AsyncDisplayKit
import RxSwift

class VCSampleModals : ASDKViewController<SampleModal> {
    static func spawn() -> VCSampleModals {
        return tell( VCSampleModals.init(node: .init()) ) {
            $0.title = "Modals"
        }
    }
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        node.button_float.rxTap.subscribe(onNext: { tap in
            let sheet = ReFloatSheetController.create(child: UIViewController())
            self.present(sheet, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        node.button_detach.rxTap.subscribe(onNext: { tap in
            let vc = UIViewController()
            vc.preferredContentSize = .init(width: 300, height: 300)
            
            let sheet = ReDatachedSheetController.create(child: vc)
            self.present(sheet, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        node.button_popup.rxTap.subscribe(onNext: { tap in
            
        }).disposed(by: disposeBag)
        
        node.button_popover.rxTap.subscribe(onNext: { tap in
            
        }).disposed(by: disposeBag)
        
    }
}

class SampleModal : ASDisplayNode {
    
    var scrollNode : ReScrollNode!
    
    var button_float = ReButton()
    var button_detach = ReButton()
    var button_popup = ReButton()
    var button_popover = ReButton()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
        
        self.button_float   .set(text: "FloatSheet", config: ButtonConfig.DARK)
        self.button_detach  .set(text: "DetachedSheet", config: ButtonConfig.DARK)
        self.button_popup   .set(text: "PopupSheet", config: ButtonConfig.DARK)
        self.button_popover .set(text: "PopoverSheet", config: ButtonConfig.DARK)
        
        
        self.scrollNode = tell(.init()) {
            $0?.layoutSpecBlock = {
                [unowned self] _,_ in
                self.layoutContent()
            }
        }
    }
    
    
    func layoutContent() -> ASLayoutSpec {
        ASStackLayoutSpec.vStackSpec {
            button_float
            button_detach
            button_popup
            button_popover
        }
        .align()
        .insetSpec(self.safeAreaInsets)
        .insetSpec(.init(horizontal: 20, vertical: 10))
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec {
            self.scrollNode
        }
    }
    
    override func safeAreaInsetsDidChange() {
        setNeedsLayout()
    }
}




