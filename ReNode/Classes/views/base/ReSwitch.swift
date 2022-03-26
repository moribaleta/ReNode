//
//  ReSwitch.swift
//  ReNode
//
//  Created by Alec on 3/24/22.
//

import UIKit
import RxSwift
import AsyncDisplayKit

public class ReSwitch : ResizeableNode {
    
    public var rxSwitch : Observable<Bool> {
        return emitSwitch
    }
    
    fileprivate var emitSwitch = PublishSubject<Bool>()
    
    public var uiswitch : UISwitch {
        return self.view as! UISwitch
    }
    
    public override init() {
        super.init()
        self.setViewBlock { () -> UIView in
            return UISwitch()
        }
        //backgroundColor = .white
        self.style.preferredSize = self.uiswitch.intrinsicContentSize
    }
    
    public override func didLoad() {
        super.didLoad()
        //self.style.preferredSize = self.uiswitch.intrinsicContentSize
        
        self.uiswitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: UIControl.Event.valueChanged)
    }
    
    deinit {
        self.emitSwitch.dispose()
    }
    
    @objc func switchChanged(_ _switch: UISwitch) {
        self.emitSwitch.onNext(_switch.isOn)
    }
}



open class ReToggle : ResizeableNode {
    
    public var text         = ReTextNode()
    public var toggle       = ReSwitch()
    public var fontsize     = CGFloat(10)
    public var fontcolor    : UIColor = .black
    public var type         : ReTextType = .bodyText
    public var data         = ""
    
    
    public var isOn : Bool {
        get {
            self.toggle.uiswitch.isOn
        } set {
            self.toggle.uiswitch.isOn = newValue
        }
    }
    
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    public convenience init(text: String, size: CGFloat = 10, fontcolor : UIColor = UIColor.black, type: ReTextType = .bodyText) {
        self.init()
        self.data       = text
        self.fontsize   = size
        self.fontcolor  = fontcolor
        self.type       = type
        self.text.attributedText = Common.attributedString( text, attribute: type, size: fontsize, color: fontcolor)
    }
    
    open override func didLoad() {
        super.didLoad()
        self.text.attributedText    = Common.attributedString( data, attribute: type, size: fontsize, color: fontcolor)
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        toggle.style.preferredSize = toggle.view.intrinsicContentSize
        
        let children = (text.attributedText?.string ?? "").isEmpty ? [ toggle ] : [toggle, text ]
        return ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .center, children: children)
    }
}
