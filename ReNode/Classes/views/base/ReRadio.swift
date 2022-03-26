//
//  ReRadio.swift
//  ReNode
//
//  Created by Mini on 2/28/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift

public class ReRadio : ReButton {
    
    public override init() {
        super.init()
    }
    
    var dot = ASDisplayNode()
    var circle = ASDisplayNode()
    
    public var object : Stringable? {
        didSet {
            self.set(text: object?.string ?? "")
            setNeedsLayout()
        }
    }
    
    var isOn: Bool = false {
        didSet {
            if isOn {
                dot.isHidden = false
            } else {
                dot.isHidden = true
            }
            
            setNeedsLayout()
        }
    }

    
    public override func didLoad() {
        super.didLoad()
        self.circle.borderWidth = 1
        self.circle.cornerRadius = 10
        self.circle.borderColor = Common.color.border_line.uicolor.cgColor
        
        dot.cornerRadius = 6
        dot.backgroundColor = Common.baseColor.violet.uicolor
        dot.isHidden = true
        
        if let val = object {
            self.set(text: val.string)
        }
        
        //self.rxTap.subscribe(onNext: { [weak self] tap in
        //    self?.updateChecked()
        //}).disposed(by: disposeBag)
    }
    
    //@objc func updateChecked() {
    //    isOn = !isOn
    //    //sendActions(forControlEvents: .valueChanged, with: nil)
    //}
    
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        self.circle.style.preferredSize = .init(width: 20, height: 20)
        self.circle.style.flexGrow = 0
        self.circle.style.flexShrink = 1
        
        self.dot.style.preferredSize =  .init(width: 12, height: 12)
        self.dot.style.flexGrow = 0
        self.dot.style.flexShrink = 0
        
        let circle_layout = circle
            .overlaySpec {
                self.dot.centerSpec(.minimumXY, .XY)
            }
        
        if (node_text.attributedText?.string ?? "").isEmpty {
            return circle_layout.centerSpec(.minimumXY, .XY)
        }
        
        return ASLayoutSpec.hStackSpec {
            circle_layout
            node_text
        }
        .spacing(10)
        .justify(.start)
        .align(.center)
        
    }
    
    
    @available(*, unavailable, message:"Child can't set icon, please use set(text:)")
    public override func set(icon: String, text: String?, config: ButtonConfig) {
        // do nothing
    }
    
    open func set(text: String) {
        let font = UIFont.systemFont(ofSize: ButtonConfig.PLAIN.fontSize, weight: .regular)
        node_text.attributedText = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : ButtonConfig.PLAIN.fontColor])
    }
    
}
