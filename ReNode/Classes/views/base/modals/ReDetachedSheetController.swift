//
//  ReDetachedSheetController.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//


import Foundation
import Foundation
import UIKit
import RxSwift
import RxKeyboard
import AsyncDisplayKit

/**
 vc for displaying a form sheet like view but doesnt changes from regular to compact on trait changes
 */
open class ReDatachedSheetController : ASDKViewController<ReDetachSheetView>, ReModalType {
    
    public var navigation       = UINavigationController()
    public weak var delegate    : ReFloatSheetDelegate?
    var disposeBag              = DisposeBag()
    
    open override var preferredContentSize: CGSize {
        didSet {
            self.navigation.preferredContentSize = self.preferredContentSize
        }
    }
    
    public var isBackgroundDismiss : Bool = true {
        didSet{
            self.node.filler.isUserInteractionEnabled = self.isBackgroundDismiss
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
                - default: false
            - keyboardAdjust: determines if the view should compensate for the keyboard
                - default: false
     */
    public static func create(
        child             : UIViewController,
        hideNavigationBar : Bool = true
    )  -> ReDatachedSheetController {
        
        let view                        = ReDetachSheetView()
        view.hideNavigationBar          = hideNavigationBar
        view.preferredContentSize       = child.preferredContentSize
        view.direction                  = .up
        
        let vc                          = ReDatachedSheetController(node: view)
        vc.navigation.viewControllers   = [child]
        vc.modalPresentationStyle       = .overFullScreen
        vc.modalTransitionStyle         = .crossDissolve
        return vc
    }
    
    deinit {
        self.navigation.removeFromParent()
        self.delegate   = nil
        self.disposeBag = .init()
    }
    
    open override func loadView() {
        super.loadView()
        self.addChild(navigation)

        self.node.setChild(view: self.navigation.view)
        
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
        
        self.navigation.setNavigationBarHidden(
            self.node.hideNavigationBar,
            animated: false
        )
    }

    func pageSheetDidDismiss(){
        self.navigation.removeFromParent()
        
        self.dismiss(animated: false) {
            self.delegate?.pageSheetDidDismiss()
        }
    }
    
    func pageSheetWillClose(_ animated: Bool = true){
        (self.delegate?.pageSheetWillDimiss() ?? Observable<Bool>.just(true))
            .filter({ $0 }).single()
            .subscribe(onNext: { [unowned self] _ in
                self.node.onWillCloseDisplay(animated)
            }).disposed(by: self.disposeBag)
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



open class ReDetachSheetView : ReFloatSheetView {
    
    public var preferredContentSize = CGSize.zero
    
    open func setChild(view: UIView){
        self.child = tell(ReDetachSheetChildContainer()) {
            $0.child = .init(viewBlock: {
                view
            })
        }
        
        self.setNeedsLayout()
    }
    
    open override func didLoad() {
        DispatchQueue.main.async {
            self.onDidDisplay()
        }
        
        KeyboardUtilities
            .instance
            .rxKeyboard
            .map{
                props -> CGFloat in
                
                if props.isFloating || props.height == .nan || props.height < 0 {
                    return 0
                } else if props.height > 550 {
                    return 550
                } else {
                    return props.height
                }
            }
            .subscribe(onNext: {
            [unowned self] height in
                self.keyboardHeight = height > 100 ? height : 0
                self.setNeedsLayout()
        }).disposed(by: self.disposeBag)
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASLayoutSpec
            .vStackSpec {
                self.child
                    .flex(grow: 1, shrink: 1)
                    .frame(
                        maxWidth   : self.preferredContentSize.width,
                        maxHeight  : self.preferredContentSize.height
                    )
                    .insetSpec(10)
            }
            .justify    ( self.keyboardHeight != 0 && self.isCompact ? .end : .center)
            .align      (.center)
            .insetSpec  (.bottomInset(self.keyboardHeight))
            .backgroundSpec {
                self.filler
                    .flex(grow: 1, shrink: 1)
            }
    }//layoutSpecThatFits
    
}//SULDetachSheetView


open class ReDetachSheetChildContainer : ReFloatSheetChildContainer {
    
    public override init() {
        super.init()
        self.clipsToBounds = true
    }
    
    open override func didLoad() {
        super.didLoad()
        self.cornerRadius = 10
    }
    open override func onLayoutDidChange(prev: UIUserInterfaceSizeClass?, current: UIUserInterfaceSizeClass) {
        //leave it blank so the super class func wont be called
        //self.cornerRadius = 10
        //self.setNeedsLayout()
    }
    
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.child
            .flex(grow: 1, shrink: 1)
            .insetSpec(2)
    }
}//SULFloatSheetViewChildContainer

