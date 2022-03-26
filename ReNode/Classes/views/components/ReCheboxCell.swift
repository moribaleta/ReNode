//
//  ReCheboxCell.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import UIKit


public struct ReCheckBoxCellConfig {
    public var icon            : Icon?
    public var iconColor       : UIColor
    public var backgroundColor : UIColor
    
    public init(
        icon            : Icon?,
        iconColor       : UIColor,
        backgroundColor : UIColor
    ) {
        self.icon               = icon
        self.iconColor          = iconColor
        self.backgroundColor    = backgroundColor
    }
    
    public static var defaultActive : ReCheckBoxCellConfig {
        .init(
            icon            : .utilCheck,
            iconColor       : .black,
            backgroundColor : .white)
    }
    
    public static var defaultInActive : ReCheckBoxCellConfig {
        .init(
            icon            : nil,
            iconColor       : .clear,
            backgroundColor : .white)
    }
    
    public static var violet : ReCheckBoxCellConfig  {
        .init(
            icon                : .utilCheck,
            iconColor           : .white,
            backgroundColor     : Common.baseColor.violet.uicolor)
    }
}

/**
 ui cell node that contains checkbox
 - similar to SelectorCellNode
 - both the text and circles are clickable and emits rxCheckTapped
 - for future discussion if this will be deprecated and moved to SelectorCellNode
 */
open class CommonCheckboxCell   : ReCellNode {
    
    public struct Theme {
        public var active    : ReCheckBoxCellConfig = .defaultActive
        public var inactive  : ReCheckBoxCellConfig = .defaultInActive
        
        
        public init(active  : ReCheckBoxCellConfig = .defaultActive,
                    inactive: ReCheckBoxCellConfig = .defaultInActive) {
            self.active     = active
            self.inactive   = inactive
        }
    }
    
    public let checkSize        : CGFloat       = 24
    
    public var iconSize         : CGFloat   {
        return self.checkSize * 0.8
    }
    
    public var circle           : ASDisplayNode = ASDisplayNode()
    public var checkbox         : ASTextNode    = ASTextNode()
    public var text             : ASTextNode    = ASTextNode()
    public var _isChecked       : Bool          = false
    public var data             : String        = "String"
    public var shouldEmitTap    : Bool          = false
    public var theme            : Theme         = .init()
    
    ///obs for emiting check button
    public var rxCheckTapped    : Observable<Void> {
        return emitCheckTapped.asObservable()
    }
    
    private var emitCheckTapped = PublishSubject<Void>()
    
    deinit {
        self.emitCheckTapped.dispose()
    }
    
    /**
     * sets the check value and set state
     */
    public var isChecked : Bool {
        get {
            return _isChecked
        }
        set {
            if _isChecked != newValue {
                
                _isChecked = newValue
                
                // change UI
                self.set(state: newValue)
            }
        }
    }
    
    
    public override init() {
        super.init()
        self.circle.borderColor         = Common.color.border_line.uicolor.cgColor
        self.circle.borderWidth         = 1
        self.circle.backgroundColor     = .white
        self.circle.cornerRadius        = 4
    }
    
    public convenience init(label: String, search: String? = nil, isChecked: Bool = false, shouldEmitTap: Bool = false, theme: Theme = .init()) {
        self.init()
        self.theme = theme
        self.set(label: label, search: search)
        self.set(state: isChecked)
        self.shouldEmitTap = shouldEmitTap
    }
    
    open override func didLoad() {
        super.didLoad()
        
        if self.shouldEmitTap {
            let tapper = UITapGestureRecognizer(target: self, action: #selector(checkTapped))
            self.view.addGestureRecognizer(tapper)
        }
    }
    
    @objc
    private func checkTapped() {
        self.emitCheckTapped.onNext(())
    }
    
    /** change selected state */
    open func set(state: Bool) {
        self.isChecked = state
        
        let theme = state ? self.theme.active : self.theme.inactive
        
        tell(state ?
             NSAttributedString(asIcon: theme.icon ?? .utilCheck, iconSize: iconSize, foreground: theme.iconColor) :
                NSAttributedString()) {
            self.checkbox.attributedText = $0.aligned(.center)
        }
        
        self.circle.backgroundColor = theme.backgroundColor
        
        self.setNeedsDisplay()
        self.setNeedsLayout()
    }
    
    open func set(label: String, search: String? = nil) {
        data = label
        text.attributedText = Common.attributedString(label, attribute: .bodyText).highlight(search ?? "")
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        make(
            ASLayoutSpec.hStackSpec {
                ASLayoutSpec.conditional(self.isChecked) {
                    self.circle
                        .overlaySpec {
                            self.checkbox
                                .centerSpec(.minimumXY, .XY)
                        }
                } false: {
                    self.circle
                }//conditional
                self.text.flex(grow: 1, shrink: 1)
            }//hStackSpec
                .spacing()
                .align(.center)
                .insetSpec(horizontal: 2, vertical: 10)) {
                    self.circle.frame(equal: checkSize)
                    self.checkbox.frame(equal: iconSize)
                }
    }//layoutSpecThatFits
    
}//UIMedicalHistorySelectorCheckbox

