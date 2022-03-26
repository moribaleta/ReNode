//
//  SampleButtons.swift
//  ReNodeSample
//
//  Created by Mini on 1/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReNode


class VCSampleButtons : ASDKViewController<SampleButtons> {
    static func spawn() -> VCSampleButtons {
        return tell( VCSampleButtons.init(node: .init()) ) {
            $0.title = "Buttons"
        }
    }
    
}

class SampleButtons : ResizeableNode {
    
    var button_link = ReButton()
    
    var button_dark = ReButton()
    var button_green = ReButton()
    var button_violet = ReButton()
    
    var button_light = ReButton()
    
    var button_blue = ReButton()
    
    
    var icon30_clear = ReButton()
    var icon30_gray = ReButton()
    var icon36_gray = ReButton()
    var icon36_black = ReButton()
    var icon_close = ReButton()
    var icon_dismiss = ReButton()
    
    var save            = ReButton()
    var save_disable    = ReButton()
    var add             = ReButton()
    
    
    var icontext    = ReButton()
    
    
    var badgeLabelNode  : ReTextNode!
    var badgeNode1      : ReBadgeButton!
    var badgeNode2      : ReBadgeButton!
    
    var colorPickerNodeEntry : ReColorPickerEntry!
    var colorPickerNode : ReColorPicker!
    
    var switchNode      : ReSwitch!
    
    var scrollNode  : ReScrollNode!
    
    var sections : [ASStackLayoutSpec] = []
    
    override init() {
        super.init()
        backgroundColor = .white
        
        button_link     .set(icon: "", text: "Link"     , config: .LINK     )
        
        button_dark     .set(icon: "", text: "DARK"     , config: .DARK     )
        button_green    .set(icon: "", text: "GREEN"    , config: .GREEN    )
        button_violet   .set(icon: "", text: "VIOLET"   , config: .VIOLET   )
        
        button_light    .set(icon: "", text: "LIGHT"    , config: .LIGHT    )
        
        button_blue     .set(icon: "", text: "Round Blue", config: .ROUND_BLUE)
        
        icon30_clear    .set(icon: Icon.actionAdd.rawValue, text: "", config: .ICON30_CLEAR)
        icon30_gray     .set(icon: Icon.actionAdd.rawValue, text: "", config: .ICON30_GRAY)
        icon36_gray     .set(icon: Icon.actionAdd.rawValue, text: "", config: .ICON36_GRAY)
        icon36_black    .set(icon: Icon.actionAdd.rawValue, text: "", config: .ICON36_BLACK)
        
        icontext        .set(icon: Icon.actionAdd.rawValue, text: "ADD", config: .DARK)
        
        self.save.set(config: .SAVE)
        self.save_disable.set(config: .SAVE_DISABLED)
        self.add.set(config: .ADD)
        self.icon_close.set(config: .ICON_CLOSE)
        self.icon_dismiss.set(config: .DISMISS_KEYBOARD)
        
        
        badgeLabelNode  = .init("Badge Button")
        //directly add specific properties
        badgeNode1      = tell(.init(icon: .menuMessenger, size: .equal(40), showBorder: true)) {
            $0?.reactiveUpdate(value: 1)
        }
        
        //pass a config to the badge button
        
        let config = ReBadgeButtonConfig(
            icon            : .actionSend,
            iconColor       : .white,
            size            : .equal(40),
            showBorder      : true,
            backgroundColor: Common.baseColor.blue.uicolor)
        
        badgeNode2       = tell(.init(config: config)) {
            $0?.reactiveUpdate(value: 1)
        }
        
        
        self.colorPickerNode        = .init()
        self.colorPickerNodeEntry   = .init(label: "Color Picker Entry", required: true)
        
        self.scrollNode = tell(.init()) {
            $0?.layoutSpecBlock = {
                [unowned self] _,_ in
                self.layoutContent()
            }
        }
        
        self.sections = [
            ASLayoutSpec
                .vStackSpec{
                    ReTextNode("Basic Buttons")
                    
                    ASLayoutSpec
                        .vStackSpec{
                            self.button_link
                            self.button_dark
                            self.button_green
                            self.button_violet
                            self.button_light
                            self.button_blue
                            self.icon30_clear
                            self.icon30_gray
                            self.icon36_gray
                            self.icon36_black
                            self.icontext
                        }
                        .align()
                        .insetSpec(.init(horizontal: 10, vertical: 0))
                    
                    self.border1
                }
            ,
            ASLayoutSpec
                .vStackSpec{
                    ReTextNode("Default Buttons")
                    
                    ASLayoutSpec
                        .hStackSpec{
                            self.save
                            self.save_disable
                            self.add
                        }
                        .align()
                        .insetSpec(.init(horizontal: 10, vertical: 0))
                    
                    self.border2
                },
            ASLayoutSpec
                .vStackSpec{
                    ReTextNode("Default Icon Buttons")
                    ASLayoutSpec
                        .hStackSpec{
                            self.icon_close
                            self.icon_dismiss
                        }
                        .align()
                        .insetSpec(.init(horizontal: 10, vertical: 0))
                    
                    self.border3
                },
            
            ASLayoutSpec
                .vStackSpec{
                    ReTextNode("Color Picker Buttons")
                    
                    ASLayoutSpec
                        .vStackSpec{
                            self.colorPickerNode
                            self.colorPickerNodeEntry
                        }
                        .align()
                        .insetSpec(.init(horizontal: 10, vertical: 0))
                    
                    self.border4
                },
            
            ASLayoutSpec
                .vStackSpec{
                    ReTextNode("Badge Buttons")
                    
                    ASLayoutSpec
                        .hStackSpec {
                            self.badgeNode1
                            self.badgeNode2
                        }
                        .justify(.center)
                        .align(.center)
                }
        ]
        self.switchNode = ReSwitch()
    }
    
    lazy var border1 = ReBorderNode.init(direction: .horizontal, colorType: Common.baseColor.black)
    lazy var border2 = ReBorderNode.init(direction: .horizontal, colorType: Common.baseColor.black)
    lazy var border3 = ReBorderNode.init(direction: .horizontal, colorType: Common.baseColor.black)
    lazy var border4 = ReBorderNode.init(direction: .horizontal, colorType: Common.baseColor.black)
    lazy var border5 = ReBorderNode.init(direction: .horizontal, colorType: Common.baseColor.black)
    
    
    func layoutContent() -> ASLayoutSpec {
        
        ASStackLayoutSpec.vStackSpec {
            self.sections
                .map {
                    $0.align().spacing(20)
                }
            
            self.switchNode
        }
        .spacing(40)
        .align()
        .insetSpec(horizontal: 10)
        .insetSpec(self.safeAreaInsets)
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
