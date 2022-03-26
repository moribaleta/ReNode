//
//  ReCheckbox.swift
//  ReNode
//
//  Created by Mini on 2/27/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

open class  ReCheckbox : ReButton {
    
    
    public var isChecked: Bool = false {
        didSet {
            if isChecked {
                node_icon.attributedText = NSAttributedString(string: Icon.utilCheck.rawValue, attributes: [
                    .font: UIFont.icon(from: Fonts.SeriousMD, ofSize: 16),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: tell(NSMutableParagraphStyle()) {
                        $0.alignment = .center
                        $0.minimumLineHeight = 14
                    }
                ])
                box.backgroundColor = Common.baseColor.violet.uicolor
            } else {
                node_icon.attributedText = nil
                box.backgroundColor = Common.baseColor.white.uicolor
            }
            
            setNeedsLayout()
        }
    }
    
    public private(set) var box = ASDisplayNode()
    
    public override init() {
        super.init()
        self.box.borderColor = Common.color.border_line.uicolor.cgColor
        self.box.borderWidth = 1
        self.box.border(radius: 4)
    }
    
    open override func didLoad() {
        super.didLoad()
        self.rxTap.subscribe(onNext: { [weak self] tap in
            self?.updateChecked()
        }).disposed(by: self.disposeBag)
    }
    
    @objc func updateChecked() {
        isChecked = !isChecked
        //sendActions(forControlEvents: .valueChanged, with: nil)
    }
    
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        box.style.preferredSize = .init(width: 24, height: 24)
        box.style.flexGrow = 0
        box.style.flexShrink = 0
        
        let checkbox_layout = box.overlaySpec {
            self.node_icon.centerSpec(.minimumXY, .XY)
        }
        
        if (node_text.attributedText?.string ?? "").isEmpty {
            return checkbox_layout.centerSpec(.minimumXY, .XY)
        }
        
        return ASLayoutSpec.hStackSpec {
                checkbox_layout
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
