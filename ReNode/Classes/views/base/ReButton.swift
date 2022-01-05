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
import AVFoundation

open class ReButton : ASButtonNode {
    
    public var rxTap : Observable<Void> {
        self.emitTap.asObservable()
    }
    
    fileprivate var emitTap = PublishSubject<Void>()
    
    deinit {
        self.emitTap.dispose()
    }
    
    open override func didLoad() {
        super.didLoad()
        
        self.addTarget(self, action: #selector(onTap), forControlEvents: .touchUpInside)
    }
    
    @objc private func onTap(sender: Any) {
        self.emitTap.onNext(())
    }
    
    public func set(icon: String, text: String, config: ButtonConfig) {
        
        
        let font = UIFont.systemFont(ofSize: config.fontSize, weight: .medium)
        self.setTitle(text, with: font, with: config.fontColor, for: .normal)
        
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
    
//    /// set string without chaing button style
//    public func setText(text: String) {
//
//    }
    
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
    
}
