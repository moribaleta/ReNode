//
//  ReFloat.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation
import UIKit
import RxSwift
import RxKeyboard
import AsyncDisplayKit

public protocol ReFloatSheetDelegate : AnyObject {
    func pageSheetWillDimiss() -> Observable<Bool>
    func pageSheetDidDismiss()
    func pageSheetClose(_ animated: Bool)
    ///observable to child if it wants the child to close
    var rxChildWillClose : Observable<Void>?{get}
}

public extension ReFloatSheetDelegate {
    
    func pageSheetClose(_ animated: Bool = false){
        
    }
}


open class ReFloatSheetController : ASDKViewController<ReFloatSheetView>, ReModalType{
    
    public var navigation           = UINavigationController()
    public weak var delegate        : ReFloatSheetDelegate?
    var disposeBag                  = DisposeBag()
    
    open override var preferredContentSize: CGSize {
        didSet {
            self.navigation.preferredContentSize = self.preferredContentSize
        }
    }
    
    /**
        creates a floatsheet
        * parameters:
            - child : initial child view to be added to the navigation
            - direction: where the view will attach
                - default: .right
            - attachBottom: determines if the view will be attached to the bottom screen
                - default: false
            - hideNavigationBar: determines if the navigation controller will be hidden
                - default: true
            - expanded: determines if the view will be larger
                - defualt: false
     */
    public static func create(child: UIViewController,
                              direction: ASScrollDirection = .right,
                              attachBottom: Bool = false,
                              hideNavigationBar: Bool = true,
                              expanded: Bool = false)  -> ReFloatSheetController {
        
        let view                = ReFloatSheetView()
        view.direction          = direction
        view.attachBottom       = attachBottom
        view.hideNavigationBar  = hideNavigationBar
        view.expanded           = expanded
        
        let vc                          = ReFloatSheetController(node: view)
        vc.navigation.viewControllers   = [child]
        vc.modalPresentationStyle       = .overFullScreen
        vc.modalTransitionStyle         = .crossDissolve
        return vc
    }
    
    deinit {
        self.navigation.removeFromParent()
        self.delegate = nil
        self.disposeBag = .init()
    }
    
    open override func loadView() {
        super.loadView()
        self.addChild(navigation)

        self.node.child.child = .init(viewBlock: { [weak self] () -> UIView in
            return self?.navigation.view ?? UIView()
        })
        
        self.delegate?.rxChildWillClose?.subscribe(onNext: {
            [unowned self] in
            self.pageSheetWillClose()
        }).disposed(by: self.disposeBag)
        
        self.node.rxOnTap.subscribe(onNext: {
            [unowned self] in
            self.pageSheetWillClose()
        }).disposed(by: self.disposeBag)
        
        self.node.rxOnDidClose.subscribe(onNext: {
            [unowned self] in
            self.pageSheetDidDismiss()
        }).disposed(by: self.disposeBag)
        
        self.navigation.setNavigationBarHidden(self.node.hideNavigationBar, animated: false)
    }

    func pageSheetDidDismiss(){
        self.navigation.removeFromParent()
        self.dismiss(animated: false) {
            self.delegate?.pageSheetDidDismiss()
        }
    }
    
    func pageSheetWillClose(_ animated: Bool = true){
        _ = (self.delegate?.pageSheetWillDimiss() ?? Observable<Bool>.just(true))
            .filter({ $0 }).single()
        .subscribe(onNext: { [unowned self] _ in
            self.node.onWillCloseDisplay(animated)
        })
    }
    
    public func popViewController(){
        DispatchQueue.main.async { [weak self] () -> Void in
            self?.navigation.popViewController(animated: true)
        }
    }
    
    public func pushViewController(vc: UIViewController){
        DispatchQueue.main.async { [weak self] () -> Void in
            self?.navigation.pushViewController(vc, animated: true)
        }
    }
    
    public func dismiss(_ animated: Bool = false) {
        self.pageSheetWillClose(animated)
    }
}


open class ReFloatSheetView : BackgroundDisplay {
    
    public var child = ReFloatSheetChildContainer()
    
    public var direction    : ASScrollDirection = .right
    
    public var attachBottom : Bool = false {
        didSet{
            self.child.isAttachBottom = self.attachBottom
        }
    }
    
    public var adaptToChildSize : Bool = false
    
    public var isCompact: Bool {
        self.asyncTraitCollection().horizontalSizeClass == .compact || UIDevice.current.userInterfaceIdiom == .phone
    }
    
    public var hideNavigationBar    : Bool = true
    
    public var expanded : Bool = true
    
    //public var filler = ASDisplayNode()
    
    public var rxOnTap : Observable<Void> {
        return emitOnTap.asObservable()
    }
    
    public var rxOnDidClose : Observable<Void> {
        return emitOnDidClose.asObservable()
    }
    
    public var dismissKey       = ReButton()
    
    public var emitOnTap        = PublishSubject<Void>()
    public var emitOnDidClose   = PublishSubject<Void>()
    
    var disposeBag              = DisposeBag()
    public var filler           = ASDisplayNode()
    
    //var swipeGesture : UISwipeGestureRecognizer!
    
    public var keyboardHeight: CGFloat = .zero
    
    public override init() {
        super.init()
        self.backgroundColor = Common.baseColor.black.uicolor.withAlphaComponent(0.5)
        self.child.layer.opacity = 0
        self.filler.isUserInteractionEnabled = true
        let tapper = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.filler.view.addGestureRecognizer(tapper)
        self.cornerRadius = 0
    }

    
    open override func didLoad() {
        super.didLoad()
        
        DispatchQueue.main.async {
            self.onDidDisplay()
        }
        
        KeyboardUtilities.instance.rxKeyboard.subscribe(onNext: {
            [unowned self] props in
            self.keyboardHeight = props.isFloating ? 0 : props.height
            self.setNeedsLayout()
        }).disposed(by: self.disposeBag)
    }
    
    func onDidDisplay(){
        self.child.view.transform   = self.isCompact || self.direction == .up || self.direction == .down || self.attachBottom ? .init(translationX: 0, y: 500) : .init(translationX: 100, y: 0)
        
        UIView.animate(
            withDuration: 0.1, delay: 0.1,
            options: .curveEaseOut,
            animations: {
                self.child.view.transform   = .identity
                self.child.layer.opacity    = 1
                self.view.layoutIfNeeded()
                
        })
    }
    
    func onWillCloseDisplay(_ animated: Bool = true){
        if animated {
            UIView.animate(
                withDuration: 0.2, delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.child.view.transform   = self.asyncTraitCollection().horizontalSizeClass == .compact || self.direction == .up || self.direction == .down || self.attachBottom ? .init(translationX: 0, y: 1000) : .init(translationX: 400, y: 0)
                    self.child.layer.opacity    = 0
                    self.view.layoutIfNeeded()
            }){ completed in
                self.emitOnDidClose.onNext(())
            }
        } else {
            self.emitOnDidClose.onNext(())
        }
    }
    
    @objc func onTap(sender: Any?) {
        self.emitOnTap.onNext(())
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var justifyContent = ASStackLayoutJustifyContent.center
        
        if self.expanded && !self.isCompact {
            self.child.style.maxWidth   = .init(unit: .points,   value: constrainedSize.max.width - 20)
        } else {
            self.child.style.maxWidth   = .init(unit: .points,   value: 600)
        }
        
        self.child.style.height     = .init(unit: .fraction, value: 1)
        
        if self.isCompact {
            self.child.style.width = .init(unit: .fraction, value: 1)
        } else {
            if self.direction == .left || self.direction == .right {
                self.child.style.width = .init(unit: .points, value: 380)
                justifyContent = self.direction == .left ? .start : .end
            } else {
                self.child.style.width = .init(unit: .points, value: constrainedSize.max.width * 0.8)
            }
        }
        
        let stack = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: justifyContent,
                                      alignItems: self.isCompact ? .stretch : .start,
                                      children: [self.child])
        
        stack.style.height = .init(unit: .fraction, value: 1)
        
        var insetASInset : ASInsetLayoutSpec!
        
        var inset : UIEdgeInsets = .init()
        
        if let _inset = UIScreen.main.safeAreaInset() {
            inset = .init(top: _inset.top + 10, sides: 10, bottom: 10)
        }
        
        if self.isCompact {
            insetASInset = .init(insets: .init(top: 0, sides: 0, bottom: self.keyboardHeight), child: stack)
        } else if self.attachBottom {
            insetASInset = .init(insets: .init(top: 100, sides: 10, bottom: self.keyboardHeight), child: stack)
        } else {
            insetASInset = .init(insets: inset, child: stack)
        }
        
        insetASInset.style.flexGrow     = 1
        insetASInset.style.flexShrink   = 1
        self.filler.style.flexGrow      = 1
        self.filler.style.flexShrink    = 1
        return ASOverlayLayoutSpec(child: filler, overlay: insetASInset)
    }
 
}//SULFloatSheetView

open class ReFloatSheetChildContainer : BackgroundDisplay {
    
    public var child = ASDisplayNode()
    public var isAttachBottom : Bool = false
    
    public override init() {
        super.init()
        self.clipsToBounds = true
    }
    
    open override func onLayoutDidChange(prev: UIUserInterfaceSizeClass?, current: UIUserInterfaceSizeClass) {
        self.cornerRadius = current == .compact ? 0 : 10
    
        if #available(iOS 11.0, *), isAttachBottom {
            if isAttachBottom {
                view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
            }
        }
        self.setNeedsLayout()
    }
    
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var inset = UIEdgeInsets.zero
        
        let isCompact = self.asyncTraitCollection().horizontalSizeClass == .compact || UIDevice.current.userInterfaceIdiom == .phone
        
        if #available(iOS 11.0, *), isCompact {
            
            inset = .init(top: UIScreen.main.safeAreaInset()?.top ?? 0, sides: 0, bottom: 0)
        }
        
        return ASInsetLayoutSpec(insets: inset, child: self.child)
    }
}//SULFloatSheetViewChildContainer




extension UIViewController {
    
    public var floatSheet : ReFloatSheetController? {

        var vcToCheck : UIViewController? = self
        
        while (true) {

            if (vcToCheck == nil) {

                return nil
            } else if vcToCheck is ReFloatSheetController {

                return vcToCheck as? ReFloatSheetController
            } else {

                vcToCheck = vcToCheck?.parent
            }
        }
    }
}







