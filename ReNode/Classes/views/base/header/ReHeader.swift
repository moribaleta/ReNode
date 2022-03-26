//
//  ReHeader.swift
//  DateTools
//
//  Created by Gabriel Mori Baleta on 3/23/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift

/**
 ui header that have collapse view method
 - shows save button on the right corner
 - has compact feature used on scrolling
 */
open class ReHeader : ReactiveNode<Bool> {
    
    public var closeNode           = ReButton()
    public var saveNode            = ReButton()
    
    public var titleNode           = ASTextNode()
    public var sectionNode         : ASDisplayNode? // additional views to be displayed below the title when not collapsed
    public var compactTitleNode    = ASTextNode()
    
    public var backTitle           : String?
    public var title               : String?
    
    public var backIcon            : Icon = .arrowLeft
    
    ///array contains the buttons on the right side
    public var rightDisplays       : [ASDisplayNode] = []
    
    ///changes the attributes of the save button
    public var isEditing           : Bool = false {
        didSet{
            //self.saveNode.setAttributes(title: self.isEditing ? "SAVE" : "ADD", attribute: self.isEditing ? .save : .add)
            //self.saveNode
            self.saveNode.set(
                text    : self.isEditing ? "SAVE" : "ADD",
                config  : self.isEditing ? .SAVE : .ADD)
            self.setNeedsLayout()
        }
    }
    
    public var isSafeAreaEnabled : Bool = true {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    ///determines if the save/add is enabled or hidden
    public var isSaveShown : Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var rxClose : Observable<Void> {
        return self.closeNode.rxTap
    }
    
    ///determines if the save button is shown
    public var isSaveEnabled = false {
        didSet{
            if self.isEditing {
                //self.saveNode.set(icon: <#T##String#>, text: <#T##String#>, config: <#T##ButtonConfig#>)//.setAttributes(attribute: self.isSaveEnabled ? .save : .save_disable)
                //self.saveNode.set(text: "SAVE", config: self.isSaveEnabled ? .SAVE : .SAVE_DISABLED)
                //self.saveNode.set(icon: <#T##String#>, text: <#T##String#>, config: <#T##ButtonConfig#>)
                self.saveNode.set(config: self.isSaveEnabled ? .SAVE : .SAVE_DISABLED)
                self.setNeedsLayout()
            }
        }
    }
    
    //var headerFrame : CGRect!
    
    ///determines if the header should hide or show
    public var isCollapsed : Bool = false {
        didSet {
            if oldValue != self.isCollapsed {
                self.onHeaderChange()
            }
        }
    }
    
    ///determines if the closeNode is a back navigation or close button
    public var isBack : Bool = false {
        didSet {
            self.onUpdateBack()
            self.setNeedsLayout()
        }
    }
    
    ///determines whether the compact title is at the center
    public var isCenterTitle : Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    open override func didLoad() {
        super.didLoad()
        self.compactTitleNode.layer.opacity = self.asyncTraitCollection().horizontalSizeClass == .compact ? 0 : 1
    }
    
    open func onUpdateBack(){
        /*self.closeNode.setTitle(title: (self.isCollapsed || self.asyncTraitCollection().horizontalSizeClass == .regular ? nil : self.backTitle) ?? "",
                                icon: self.isBack ? .arrowLeft : .actionClose, iconSize: 20, color: Common.color.textbody.uicolor)*/
        self.closeNode
            .set(icon: self.isBack ? .arrowLeft : .actionClose,
                 text: (self.isCollapsed || self.sizeClass == .compact ? nil : self.backTitle) ?? "",
                 config: .PLAIN)
    }
    
    open func onHeaderChange() {
        self.compactTitleNode.layer.opacity = self.isCollapsed ? 0 : 1
        self.titleNode.layer.opacity        = self.isCollapsed ? 1 : 0
        self.sectionNode?.layer.opacity     = self.isCollapsed ? 1 : 0
        
        if !self.isCollapsed {
            self.setNeedsLayout()
        }
        
        if self.isCollapsed {
            self.onUpdateBack()
            self.setNeedsLayout()
        }
        
        self.closeNode.layer.opacity = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.compactTitleNode.layer.opacity = self.isCollapsed ? 1 : 0
            self.titleNode.layer.opacity = self.isCollapsed ? 0 : 1
            self.sectionNode?.layer.opacity = self.isCollapsed ? 0 : 1
            self.closeNode.layer.opacity = 1
        }) { (bool) in
            if !self.isCollapsed {
                self.onUpdateBack()
                self.setNeedsLayout()
            }
        }
    }
    
    public override init() {
        super.init()
        //self.closeNode.setTitle(title: "", icon: .actionClose, iconSize: 20)
        self.closeNode.set(icon: .actionClose, config: .ICON30_CLEAR)
        //self.saveNode.setAttributes(attribute: .add)
        self.saveNode.set(config: .ADD)
        self.compactTitleNode.layer.opacity = 0
    }
    
    public convenience init(title: String, back: String? = nil) {
        self.init()
        self.setTitle(title, back: back)
    }
    
    /**
        sets the title
        - Parameters:
            * title : value of the header
            * back  : text shown on the back button - optional
     */
    open func setTitle(_ title: String, back: String? = nil){
        
        var back = back
        
        self.title = title
        
        if asyncTraitCollection().horizontalSizeClass == .regular && back == nil{
            back = ""
        }
        
        self.titleNode.attributedText           = Common.attributedString(title, attribute: .title)//NSAttributedString(asHeader: title, color: .black)
        self.compactTitleNode.attributedText    = Common.attributedString(title, attribute: self.asyncTraitCollection().horizontalSizeClass == .compact ? .titleText : .subtitle) //.init(asBoldData: title)
        
        self.compactTitleNode.truncationMode = .byTruncatingTail
        
        self.backTitle = back
        self.isBack = back != nil
    }
    
    var scrollDisposer = DisposeBag()
    
    ///subscriber is disabled if the view is not in compact mode
    public func bindScrollOffset(obx: Observable<CGFloat>) {
        
        self.scrollDisposer = .init()
        
        obx.filter({ [unowned self] _ -> Bool in
            return self.asyncTraitCollection().horizontalSizeClass == .compact
        }).throttle(.milliseconds(200), scheduler: MainScheduler.asyncInstance).subscribe(onNext: {
            [unowned self] offset in
            self.isCollapsed = offset > 30
        }).disposed(by: self.scrollDisposer)
    }
    
    open override func renderState(value: Bool) {
        if value != self.isSaveShown {
            self.isSaveShown = value
        }
    }
    
    open override func onLayoutDidChange(prev: UIUserInterfaceSizeClass?, current: UIUserInterfaceSizeClass) {
        if current == .regular {
            self.closeNode.set(icon: .actionClose, config: .ICON30_CLEAR)//.setTitle(title: "", icon: self.backIcon)
        } else {
            self.onUpdateBack()
        }
        
        self.setNeedsLayout()
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        self.closeNode.style.minHeight  = .init(unit: .points, value: 30)
        self.closeNode.style.minWidth   = .init(unit: .points, value: 30)
        
        
        
        let leftheader  = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start,
                                            alignItems: .center, children: [self.closeNode])
        
        let rightheader = ASStackLayoutSpec(direction: .horizontal, spacing: 5, justifyContent: .start, alignItems: .center,
                                            children: (self.isSaveShown ? [self.saveNode] : []) + self.rightDisplays )
        
        let header      = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .spaceBetween,
                                            alignItems: .stretch, children: [leftheader, rightheader])
        
        let centerTitle = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: self.compactTitleNode)
        
        self.compactTitleNode.style.maxWidth    = .init(unit: .points, value: 200)
        self.closeNode.style.maxWidth           = .init(unit: .points, value: 200)
        self.closeNode.titleNode.style.maxWidth = .init(unit: .points, value: 200)
        
        if UIApplication.shared.sizeClass == .compact {
            let stack       = ASStackLayoutSpec(direction: .vertical, spacing: 10, justifyContent: .start,
                                                alignItems: .stretch, children: [header])
            
            if !self.isCollapsed {
                stack.children?.append(titleNode)
                if let section = sectionNode {
                    stack.children?.append(section)
                }
            } else {
                if self.isCenterTitle {
                    
                    stack.children = [ASOverlayLayoutSpec(child: header, overlay: centerTitle)]
                } else {
                    leftheader.children?.append(self.compactTitleNode)
                }
            }
            
            var inset_top :CGFloat = 0
            
            if isSafeAreaEnabled {
                inset_top = safeAreaInsets.top
            }
            return ASInsetLayoutSpec(insets: .init(top: inset_top + 10, sides: 10, bottom: 10), child: stack)
        } else {
            self.compactTitleNode.style.maxWidth    = .init(unit: .points, value: 350)
            let overlay = ASOverlayLayoutSpec(child: header, overlay: centerTitle)
            return ASInsetLayoutSpec(insets: .init(top: isSafeAreaEnabled ? safeAreaInsets.top + 5 : 5, sides: 10, bottom: 5), child: overlay)
        }
        
        
    }
    
}//SULCollapsingHeader

