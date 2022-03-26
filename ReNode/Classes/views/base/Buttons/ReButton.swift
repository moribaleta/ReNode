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
    
    var text    : String = ""
    var icon    : String = ""
    
    fileprivate var emitTap = PublishSubject<Void>()
    
    let disposeBag = DisposeBag()
    
    public var rxTap : Observable<Void> {
        self.emitTap.asObservable()
    }
    
    open override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.alpha = 0.5
            } else {
                self.alpha = 1.0
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
    
    public func set(icon: String, text: String? = nil, config: ButtonConfig) {
        
        self.config = config
        
        self.icon = icon
        
        let text : String   = text ?? config.defaultText
        self.text           = text
        
        let iconSize : CGFloat      = config.shape == .icon36 ? 18 : 15
        let iconFont : UIFont       = UIFont.icon(from: Fonts.SeriousMD, ofSize: iconSize)
        node_icon.attributedText    = NSAttributedString.init(string: icon, attributes: [NSAttributedString.Key.font : iconFont, NSAttributedString.Key.foregroundColor : config.fontColor ])
 
        let font                    = UIFont.systemFont(ofSize: config.fontSize, weight: .regular)
        node_text.attributedText    = NSAttributedString.init(string: text, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : config.fontColor])
        
        
        self.backgroundColor        = config.backgroundColor
        self.borderColor            = config.borderColor?.cgColor ?? UIColor.clear.cgColor
        self.borderWidth            = 1
        
        self.isEnabled              = config.isEnabled
        
        
        switch config.shape {
        case .none:
            break
        
        case .round:
            self.contentEdgeInsets  = .init(horizontal: 20, vertical: 0)
            self.style.height       = .init(unit: .points, value: 36)
            self.cornerRadius       = 18
        
        case .rect:
            self.contentEdgeInsets  = .init(horizontal: 20, vertical: 0)
            self.style.height       = .init(unit: .points, value: 36)
            self.cornerRadius       = 6
        
        case .icon30:
            self.style.preferredSize    = .init(width: 30, height: 30)
            self.cornerRadius           = 15
            
        case .icon36:
            self.style.preferredSize    = .init(width: 36, height: 36)
            self.cornerRadius           = 18
        }
       
        self.setNeedsLayout()
    }
    
    private func buttonInset() -> UIEdgeInsets {
        switch self.config.shape {
        case .round, .rect:
            return .init(horizontal: 20, vertical: 0)
        default:
            return .zero
        }
    }
    
    public override func    layoutSpecThatFits  (_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASStackLayoutSpec.hStackSpec {
            if (node_icon.attributedText?.string.count ?? 0) > 0 {
                node_icon
            }
            if (node_text.attributedText?.string.count ?? 0) > 0 {
                node_text
            }
        }
        .spacing(5)
        .align(.center)//stackSpec
        .insetSpec(buttonInset())
        .centerSpec(.minimumXY, .XY)
    }

}

public extension ReButton {
    
    
    
    ///creates an instance of a button based on the fields given
    static func create(icon: String = "", text: String = "", config: ButtonConfig, callback : CallBack.void? = nil) -> ReButton {
        tell(ReButton()) {
            $0.set(icon: icon, text: text, config: config)
            if let callback = callback {
                $0.rxTap.bind(onNext: callback)
                    .disposed(by: $0.disposeBag)
            }
        }
    }
    
    ///creates an instance of a button based on the fields given
    static func create(icon: Icon? = nil, text: String = "", config: ButtonConfig, callback : CallBack.void? = nil) -> ReButton {
        tell(ReButton()) {
            $0.set(icon: icon?.rawValue ?? "", text: text, config: config)
            if let callback = callback {
                $0.rxTap.bind(onNext: callback)
                    .disposed(by: $0.disposeBag)
            }
        }
    }
    
    ///creates an instance of a button based on the fields given
    static func create(text: String = "", config: ButtonConfig, callback : CallBack.void? = nil) -> ReButton {
        tell(ReButton()) {
            $0.set(icon: "", text: text, config: config)
            
            if let callback = callback {
                $0.rxTap.bind(onNext: callback)
                    .disposed(by: $0.disposeBag)
            }
        }
    }
    
    func set(text: String, config: ButtonConfig) {
        self.set(icon: "", text: text, config: config)
    }
    
    func set(icon: Icon? = nil, text: String, config: ButtonConfig) {
        self.set(icon: icon?.rawValue ?? "", text: text, config: config)
    }
    
    func set(icon: Icon, config: ButtonConfig) {
        self.set(
            icon: icon.rawValue,
            text: "", config: config)
    }
    
    func set(config: ButtonConfig) {
        self.set(
            icon    : self.icon.hasValue ? self.icon : config.defaultIcon,
            text    : self.text.hasValue ? self.text : config.defaultText,
            config  : config)
    }
    
}

///TEMPLATES
public extension ReButton {
    ///ui button to dismiss keyboard actions
    static var DISMISS_KEY : ReButton {
        Self.create(icon: Icon.arrowDown.rawValue, config: .DISMISS_KEYBOARD)
    }
    
    static var SAVE : ReButton {
        Self.create(icon: "", text: "SAVE", config: .DARK)
    }
    
    static func ADD(text: String = "ADD") -> ReButton {
        Self.create(text: text, config: .ADD)
    }
    
    static func SAVE(text: String = "SAVE", isEnabled: Bool = true) -> ReButton {
        tell(Self.create(text: text, config: isEnabled ? .DARK : .SAVE_DISABLED)) {
            $0.enabled(isEnabled)
        }
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
    
    public var defaultIcon      : String
    public var defaultText      : String
    public var shape            : ButtonShape
    public var fontSize         : CGFloat
    public var fontColor        : UIColor
    public var backgroundColor  : UIColor
    public var borderColor      : UIColor? // if nil, just follow background color
    public var isEnabled        : Bool
    
    public init (shape: ButtonShape, fontSize: CGFloat, fontColor: UIColor, backgroundColor: UIColor, borderColor: UIColor?, defaultText: String = "", isEnabled: Bool = true) {
        self.shape              = shape
        self.fontSize           = fontSize
        self.fontColor          = fontColor
        self.backgroundColor    = backgroundColor
        self.borderColor        = borderColor
        self.defaultIcon        = ""
        self.defaultText        = defaultText
        self.isEnabled          = isEnabled
    }
    
    public init (shape: ButtonShape, fontSize: CGFloat = 15, fontColor: UIColor = Common.baseColor.black.uicolor, backgroundColor: UIColor = .clear, borderColor: UIColor? = .clear, defaultIcon: Icon? = nil, defaultText: String = "", isEnabled: Bool = true) {
        self.shape              = shape
        self.fontSize           = fontSize
        self.fontColor          = fontColor
        self.backgroundColor    = backgroundColor
        self.borderColor        = borderColor
        self.defaultIcon        = defaultIcon?.rawValue ?? ""
        self.defaultText        = defaultText
        self.isEnabled          = isEnabled
    }
    
    
    // TEXT ONLY
    public static let PLAIN         : ButtonConfig = .init(shape: .none, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: .clear, borderColor: .clear)
    
    public static let LINK          : ButtonConfig = .init(shape: .none, fontSize: 15, fontColor: Common.baseColor.blue.uicolor, backgroundColor: .clear, borderColor: .clear)
    
    
    
    // [ SOLID ]
    
    public static let DARK          : ButtonConfig = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.white.uicolor, backgroundColor: Common.baseColor.black.uicolor, borderColor: Common.baseColor.black.uicolor)
    
    public static let GREEN         : ButtonConfig = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.white.uicolor, backgroundColor: Common.baseColor.green.uicolor, borderColor: UIColor.clear)
    
    public static let VIOLET        : ButtonConfig = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.white.uicolor, backgroundColor: Common.baseColor.violet.uicolor, borderColor: UIColor.clear)
    
    
    
    // [ OUTLINE ]
    
    public static let LIGHT         : ButtonConfig = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: Common.baseColor.white.uicolor, borderColor: Common.baseColor.black.uicolor)
    
    
    
    // ( OUTLINE )
    
    public static let ROUND_BLUE    : ButtonConfig  = .init(shape: .round, fontSize: 15, fontColor: Common.baseColor.blue.uicolor, backgroundColor: Common.baseColor.white.uicolor, borderColor: Common.baseColor.lightgray.uicolor)
    
    public static let ROUND_BLACK   : ButtonConfig  = .init(shape: .round, fontColor: .white, backgroundColor: .black)
    
    public static let ADD           : ButtonConfig  = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: Common.baseColor.white.uicolor, borderColor: Common.baseColor.black.uicolor, defaultText: "ADD")
    
    
    // ICON
    public static let ICON30_CLEAR      : ButtonConfig = .init(shape: .icon30, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: .clear, borderColor: .clear)
    
    public static let ICON_CLOSE        : ButtonConfig = .init(shape: .icon30, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: .clear, borderColor: .clear, defaultIcon: Icon.actionClose)
    
    public static let ICON30_GRAY       : ButtonConfig = .init(shape: .icon30, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: Common.baseColor.lightgray.uicolor, borderColor: .clear)
    
    public static let ICON36_GRAY       : ButtonConfig = .init(shape: .icon36, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: Common.baseColor.lightgray.uicolor, borderColor: .clear)
    
    public static let ICON36_BLACK      : ButtonConfig = .init(shape: .icon36, fontSize: 15, fontColor: Common.baseColor.white.uicolor, backgroundColor: Common.baseColor.black.uicolor, borderColor: .clear)
    
    public static let DISMISS_KEYBOARD  : ButtonConfig = .init(shape: .icon30, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: Common.baseColor.green.uicolor, borderColor: .clear, defaultIcon: .arrowDown)
    
    public static let SAVE              : ButtonConfig = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.white.uicolor,   backgroundColor: Common.baseColor.black.uicolor,        borderColor: Common.baseColor.black.uicolor, defaultText: "SAVE")
    
    public static let SAVE_DISABLED     : ButtonConfig = .init(shape: .rect, fontSize: 15, fontColor: Common.baseColor.gray.uicolor,    backgroundColor: Common.baseColor.lightgray.uicolor,    borderColor: .clear, defaultText: "SAVE",   isEnabled: false)
    
    public static let MORE_HORIZONTAL   : ButtonConfig = .init(shape: .icon30, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: .clear, borderColor: .clear, defaultIcon: .actionMoreHorizontal)
    
    public static let MORE_VERTICAL     : ButtonConfig = .init(shape: .icon30, fontSize: 15, fontColor: Common.baseColor.black.uicolor, backgroundColor: .clear, borderColor: .clear, defaultIcon: .actionMoreVertical)
    
    
}






