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
import UIKit


open class  ReButton : ASButtonNode {
    
    let node_icon   = ASTextNode()

    let node_text   = ASTextNode()

    var config : ButtonConfig = .DARK
    
    fileprivate var emitTap = PublishSubject<Void>()
    
    public var rxTap : Observable<Void> {
        self.emitTap.asObservable()
    }
    
    open override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.alpha = 0.5
//                if let config = buttonConfig {
//                    self.backgroundColor = config.highlightColor
//                }
            } else {
                self.alpha = 1.0
//                if let config = buttonConfig {
//                    self.backgroundColor = config.backgroundColor
//                }
            }
        }
    }
    
    
    
    deinit {
        self.emitTap.dispose()
    }
    
    
    
    open override func didLoad() {
        super.didLoad()
        
        addTarget(self, action: #selector(onTap), forControlEvents: .touchUpInside)
    }
    
    @objc private func onTap(sender: Any) {
        self.emitTap.onNext(())
    }
    
    public func set(icon: String, text: String, config: ButtonConfig) {
        
        self.config = config
        
        let iconSize : CGFloat = config.shape == .icon36 ? 18 : 15
        let iconFont : UIFont = UIFont.icon(from: Fonts.SeriousMD, ofSize: iconSize)
        node_icon.attributedText = NSAttributedString.init(string: icon, attributes: [NSAttributedString.Key.font : iconFont, NSAttributedString.Key.foregroundColor : config.fontColor ])
 
        let font = UIFont.systemFont(ofSize: config.fontSize, weight: .semibold)
        node_text.attributedText = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : config.fontColor])
        
        
        self.backgroundColor = config.backgroundColor
        self.borderColor = config.borderColor?.cgColor ?? UIColor.clear.cgColor
        self.borderWidth = 1
        
        
        switch config.shape {
        case .none:
            break
        
        case .round:
            self.contentEdgeInsets = .init(horizontal: 20, vertical: 0)
            self.style.height = .init(unit: .points, value: 36)
            self.cornerRadius = 18
        
        case .rect:
            self.contentEdgeInsets = .init(horizontal: 20, vertical: 0)
            self.style.height = .init(unit: .points, value: 36)
            self.cornerRadius = 6
        
        case .icon30:
            self.style.preferredSize = .init(width: 30, height: 30)
            self.cornerRadius = 15
            
        case .icon36:
            self.style.preferredSize = .init(width: 36, height: 36)
            self.cornerRadius = 18
        }
       
    }
    
    
    public override func    layoutSpecThatFits  (_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let inside = ASStackLayoutSpec.hStackSpec {
                if (node_icon.attributedText?.string.count ?? 0) > 0 {
                    node_icon
                }
                if (node_text.attributedText?.string.count ?? 0) > 0 {
                    node_text
                }
            }
            .spacing(5)
            .align(.center)
            
        let inset : UIEdgeInsets = {
            switch self.config.shape {
            case .round, .rect:
                return .init(horizontal: 20, vertical: 0)
            default:
                return .zero
            }
        }()
        
        let insetSpec = ASInsetLayoutSpec(insets: inset, child: inside)
        
        return ASCenterLayoutSpec(centeringOptions: .XY,
                                  sizingOptions: .minimumXY,
                                  child: insetSpec)
        
        
    }

}



public enum ButtonShape {
    case none
    case rect
    case round  
    case icon30
    case icon36
}

public struct ButtonConfig {
    
    public var shape : ButtonShape
    public var fontSize : CGFloat
    public var fontColor : UIColor
    public var backgroundColor : UIColor
    public var borderColor : UIColor? // if nil, just follow background color
    
    
    public init (shape: ButtonShape, fontSize: CGFloat, fontColor: UIColor, backgroundColor: UIColor, borderColor: UIColor?) {
        
        self.shape = shape
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
    }
    
    
    // TEXT ONLY
    
    public static var LINK : ButtonConfig = .init(shape: .none, fontSize: 15, fontColor: Common.baseColor.blue.uicolor, backgroundColor: .clear, borderColor: .clear)
    
    
    
    // [ SOLID ]
    
    public static var DARK : ButtonConfig = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.white.uicolor, backgroundColor: Common.baseColor.black.uicolor, borderColor: Common.baseColor.black.uicolor)
    
    public static var GREEN : ButtonConfig = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.white.uicolor, backgroundColor: Common.baseColor.green.uicolor, borderColor: UIColor.clear)
    
    public static var VIOLET : ButtonConfig = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.white.uicolor, backgroundColor: Common.baseColor.violet.uicolor, borderColor: UIColor.clear)
    
    
    
    // [ OUTLINE ]
    
    public static var LIGHT : ButtonConfig = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: Common.baseColor.white.uicolor, borderColor: Common.baseColor.black.uicolor)
    
    
    
    // ( OUTLINE )
    
    public static var ROUND_BLUE : ButtonConfig = .init(shape: .round, fontSize: 15, fontColor: Common.baseColor.blue.uicolor, backgroundColor: Common.baseColor.white.uicolor, borderColor: Common.baseColor.lightgray.uicolor)
    
    
    
    // ICON
    public static var ICON30_CLEAR : ButtonConfig = .init(shape: .icon30, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: .clear, borderColor: .clear)
    
    public static var ICON30_GRAY : ButtonConfig = .init(shape: .icon30, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: Common.baseColor.lightgray.uicolor, borderColor: .clear)
    
    public static var ICON36_GRAY : ButtonConfig = .init(shape: .icon36, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: Common.baseColor.lightgray.uicolor, borderColor: .clear)
    
    public static var ICON36_BLACK : ButtonConfig = .init(shape: .icon36, fontSize: 15, fontColor: Common.baseColor.white.uicolor, backgroundColor: Common.baseColor.black.uicolor, borderColor: .clear)
    
}







