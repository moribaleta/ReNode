//
//  ReBadgeButton.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/17/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import UIKit

/**
 * model used to config reBadgeButton
 */
public struct ReBadgeButtonConfig {
    public var icon            : Icon
    public var iconColor       : UIColor    = Common.color.textbody.uicolor
    public var badgeColor      : UIColor    = .red
    public var size            : CGSize
    public var showBorder      : Bool       = false
    public var borderColor     : UIColor    = Common.color.border_line.uicolor
    public var backgroundColor : UIColor    = .clear
    
    public init(
        icon            : Icon,
        iconColor       : UIColor   = Common.color.textbody.uicolor,
        badgeColor      : UIColor   = .red,
        size            : CGSize,
        showBorder      : Bool      =     false,
        borderColor     : UIColor   = Common.color.border_line.uicolor,
        backgroundColor : UIColor   = .clear
    ) {
        self.icon            = icon
        self.iconColor       = iconColor
        self.badgeColor      = badgeColor
        self.size            = size
        self.showBorder      = showBorder
        self.backgroundColor = backgroundColor
    }

}//ReBadgeButtonConfig


/**
 button shows an icon that can also display a notification
 */
public class ReBadgeButton : ReButton, ReactiveProtocol {
    public typealias StateType = Int?
    
    var badgeNode       = ASTextNode()
    var iconNode        = ASTextNode()
    var backgroundNode  = ASDisplayNode()
    private var _config : ReBadgeButtonConfig!
    
    public static let DEFAULT_SIZE : CGSize = .init(width: 30, height: 30)
    
    private override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        
        tell(self.badgeNode) {
            $0.backgroundColor  = .red
            $0.border(radius: 5)
            $0.borderWidth      = 0
            $0.clipsToBounds    = true
            $0.layer.opacity    = 0
        }
    }
    
    public convenience init(
        icon            : Icon,
        iconColor       : UIColor = Common.color.textbody.uicolor,
        badgeColor      : UIColor = .red,
        size            : CGSize,
        showBorder      : Bool = false,
        backgroundColor : UIColor = .clear
    ) {
        self.init()
        self.setConfig(
            config: .init(
                icon            : icon,
                iconColor       : iconColor,
                badgeColor      : badgeColor,
                size            : size,
                showBorder      : showBorder,
                backgroundColor : backgroundColor
        ))
    }
    
    public convenience init(config: ReBadgeButtonConfig) {
        self.init()
        self.setConfig(config: config)
    }
    
    func setConfig(config: ReBadgeButtonConfig) {
        self._config = config
        
        self.iconNode.attributedText  = Common.textBuild{
            ReAttributedStringTraits.IconText(
                icon        : config.icon,
                foreground  : config.iconColor
            )
        }
        
        self.frame(size: config.size)
        self.backgroundNode.frame(size: config.size)
        self.backgroundNode.backgroundColor = config.backgroundColor
        
        if config.showBorder {
            self.backgroundNode.border(
                radius  : config.size.height / 2,
                color   : config.borderColor.cgColor
            )
        }
        
        self.badgeNode.backgroundColor = config.badgeColor
        
        self.setNeedsLayout()
    }//setConfig
    
    
    public func reactiveBind(obx: Observable<Int?>) {
        obx.distinctUntilChanged().subscribe(onNext: {
            [weak self] count in
            self?.reactiveUpdate(value: count)
        }).disposed(by: self.disposeBag)
    }//reactiveBind
    
    
    public func reactiveUpdate(value: Int?) {
        if value ?? 0 <= 0 {
            self.badgeNode.layer.opacity = 0
        } else {
            self.badgeNode.layer.opacity = 1
            self.badgeNode.attributedText = Common.attributedString("\(value!)", size: 10, color: .white).aligned(.center)
            self.setNeedsLayout()
        }
    }//reactiveUpdate
    
    
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.backgroundNode
            .overlaySpec {
                self.iconNode
                    .centerSpec(.minimumXY, .XY)
            }
            .overlaySpec {
                self.badgeNode
                    .frame(minWidth: 11, height: 12)
                    .relativeSpec(
                        horizontalPosition  : .end,
                        verticalPosition    : .start,
                        sizingOption        : .minimumSize)
            }
    }//layoutSpecThatFits
    
    
}//ReBadgeButton
