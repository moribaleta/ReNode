//
//  SampleContainer.swift
//  ReNodeSample
//
//  Created by Gabriel Mori Baleta on 3/14/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReNode
import RxCocoa
import RxSwift

class VCSampleKeyboardAware : ASDKViewController<UISampleKeyboardAware> {
    
    static func spawn() -> VCSampleKeyboardAware {
        return tell( VCSampleKeyboardAware.init(node: .init()) ) {
            $0.title = "Keyboard Aware Container"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}

struct UISampleKeyboardAwareProps : Hashable {
    var name    : String? = nil
    var value   : String? = nil
}

class UISampleKeyboardAware : ReKeyboardAwareNode<UISampleKeyboardAwareProps> {
    
    lazy var headerNode     : ReHeader = {
        .init(title: "Sample Header", back: "Sample Controller")
    }()
    
    lazy var textField1Node : ASEditableTextNode = {
        tell(ASEditableTextNode()) {
        $0.frame(
            height: 40
        )
        .fraction(width: 0.8)
        $0.border(radius: Common.text_corner_radius)
    }}()
    
    lazy var textField2Node : ASEditableTextNode = {
        tell(ASEditableTextNode()) {
        $0.frame(
            height: 40
        )
        .fraction(width: 0.8)
        $0.border(radius: Common.text_corner_radius)
    }}()
    
    lazy var textValue : ReTextNode = {
        .init()
    }()
    
    lazy var placeholderNode : RePlaceholder = {
        .init(message: "Placeholder view container")
    }()
    
    lazy var positiveToastNode : ReButton = {
        .create(
            text    : "SHOW POSITIVE",
            config  : .GREEN){
            Toast.showPositiveMessage(message: "Be Positive")
        }
    }()
    
    lazy var negativeToastNode : ReButton = {
        .create(
            text    : "SHOW NEGATIVE",
            config  : .init(
                shape           : .rect,
                fontColor       : .white,
                backgroundColor : Common.baseColor.red.uicolor)) {
            Toast.showNegativeMessage(message: "Be Negative")
        }
    }()
    
    override init() {
        super.init()
        
        self.backgroundColor            = .white
        self.relayoutOnPropsDidChange   = true
        
        let labelNode                   = ReTextNode("text field")
        
        tell (self.containerNode) {
            $0?.automaticallyManagesSubnodes = true
            $0?.layoutSpecBlock = {
                [unowned self] _,_ in
            
                ASLayoutSpec
                .vStackSpec {
                    self.headerNode
                        .fraction(width: 1)
                    labelNode
                    self.textField1Node
                    self.textField2Node
                    self.textValue
                    self.placeholderNode
                    
                    self.positiveToastNode
                    self.negativeToastNode
                }
                .align(.center)
                .justify(.center)
            }
        }
        
    }
    
    
    override func renderState(value: UISampleKeyboardAwareProps) {
        
        
    }
    
}


extension ASEditableTextNode {
    
    func reactiveBind(obx: Observable<String?>) -> Disposable {
        return obx.observe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .bind(to: self.textView.rx.text)
    }
    
    func reactiveBind(obx: Observable<String?>, property: CallBack.typeVoid<ControlProperty<String?>>) -> Disposable {
        property(self.textView.rx.text)
        return obx.observe(on: MainScheduler.asyncInstance).bind(to: self.textView.rx.text)
    }
    
    func reactiveBind(px: RePropRelay<String?>) -> Disposable {
        (self.textView.rx.text <-> px)
    }
    
}
