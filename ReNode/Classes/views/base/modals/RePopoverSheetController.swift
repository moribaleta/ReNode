//
//  RePopoverSheetController.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/23/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxKeyboard


/**
 * VC for displaying popup and transitions to full screen with the display at the bottom on compact
 */
open class RePopoverSheetController : ASDKViewController<RePopoverSheetView> {
    
    ///vc to be displayed
    var childVC         : UIViewController!
    
    ///disposeBag for the rx obs
    var disposeBag      = DisposeBag()
    
  
    /**
    creates an instance of RePopoverSheetController
      - parameters:
        - vc    : ViewController to be displayed
        - peg  : the view the popup will attach to
      */

    public static func spawn(vc: UIViewController, peg: UIView) -> RePopoverSheetController {
        tell(.init(node: .init())) {
            $0.modalPresentationStyle                       = .popover
            $0.popoverPresentationController?.delegate      = $0
            $0.popoverPresentationController?.sourceView    = peg
            $0.popoverPresentationController?.sourceRect    = peg.bounds
            
            $0.preferredContentSize = vc.preferredContentSize
            $0.childVC = vc
        }
    }//spawn
    
    open override func loadView() {
        super.loadView()
        
        self.addChild(
            self.childVC
        )
        self.node.contentSize = self.childVC.preferredContentSize
        
        if let vc = self.childVC as? ASDKViewController {
            self.node.setChildView(
                vc.node
            )
        } else {
            self.node.setChildView(
                self.childVC.view
            )
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.node
            .rxTapBackground
            .bind {
                [unowned self] in
                self.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
    }
    
}//RePopoverSheetController


extension RePopoverSheetController : UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.horizontalSizeClass == .compact {
            return .overFullScreen
        } else {
            return .popover
        }
    }
    
}//extension RePopoverSheetController : UIPopoverPresentationControllerDelegate


/**
 * displayes the content
 * if sizeClass is compact
 *  the content is shown at the bottom
 * else
 *  the content is shown respective of the contentSize set
 */
open class RePopoverSheetView : ResizeableNode {
    
    var backgroundNode          = ResizeableNode()
    var childViewNode           = RePopoverSheetChildContainer()
    var contentSize             = CGSize.zero
    var emitChangeSize          = PublishSubject<Void>()
    
    var rxTapBackground : Observable<Void> {
        self.emitTapBackground.asObservable()
    }
    
    var emitTapBackground = PublishSubject<Void>()
    
    var keyboardHeight : CGFloat = 0
    var disposeBag = DisposeBag()
    
    
    func setChildView(_ view: UIView) {
        self.childViewNode.setChildView(view)
        self.setNeedsLayout()
    }
    
    func setChildView(_ node: ASDisplayNode) {
        self.childViewNode.setChildView(node)
        self.setNeedsLayout()
    }
    
    open override func didLoad() {
        super.didLoad()
        self.backgroundNode.layer.opacity   = 0
        self.backgroundNode.backgroundColor = .black
        let tapper = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.backgroundNode.view.addGestureRecognizer(tapper)
        
        
        KeyboardUtilities.instance.rxKeyboard
            .map { $0.height }
            .bind { height in
                self.keyboardHeight = height
                self.setNeedsLayout()
            }.disposed(by: disposeBag)
    }
    
    @objc func onTap() {
        self.viewWillDisappear()
        self.emitTapBackground.onNext(())
    }
    
    func viewDidAppear() {
        self.backgroundNode.layer.opacity       = 0
        UIView.animate(withDuration: 0.1) {
            self.backgroundNode.layer.opacity   = 0.2
        }
    }
    
    func viewWillDisappear() {
        UIView.animate(withDuration: 0.1) {
            self.backgroundNode.layer.opacity = 0
        }
    }
    
    open override func onLayoutSizeDidChange(prev: CGSize?, current: CGSize) {
        if (current.width > self.contentSize.width) || self.sizeClass == .compact {
            self.viewDidAppear()
        } else {
            self.viewWillDisappear()
        }
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if UIApplication.shared.sizeClass == .compact {
            
            return self.backgroundNode
                .overlaySpec {
                    self.childViewNode
                        .frame(
                            height: min(contentSize.height + safeAreaInsets.bottom, constrainedSize.max.height - keyboardHeight - 100)
                        )
                        .insetSpec(top: 0, sides: 0, bottom: self.keyboardHeight)
                        .fraction(width: 1)
                        .relativeSpec(
                            horizontalPosition  : .start,
                            verticalPosition    : .end,
                            sizingOption        : .minimumSize
                        )
                }
        } else {
            return ASWrapperLayoutSpec {
                self.childViewNode
            }.frame(
                width   : self.contentSize.width,
                height  : self.contentSize.height
            )
        }
    }
    
    open override func safeAreaInsetsDidChange() {
        setNeedsLayout()
    }
}//RePopoverSheetView


/**
 * display container for the popover
 */
final class RePopoverSheetChildContainer : BackgroundDisplay {
    
    var content = ASDisplayNode()
    
    func setChildView(_ view: UIView) {
        self.content = .init(viewBlock: {
            view
        })
        self.setNeedsLayout()
    }
    
    func setChildView(_ node: ASDisplayNode) {
        self.content = node
        self.setNeedsLayout()
    }
    
    public override init() {
        super.init()
        self.backgroundColor    = .white
        self.cornerRadius       = 0
    }
    
    final override func onLayoutSizeDidChange(prev: CGSize?, current: CGSize) {
        let path = UIBezierPath(roundedRect         : self.bounds,
                                byRoundingCorners   :[.topRight, .topLeft],
                                cornerRadii         : .equal(Common.div_corner_radius))
        
        let maskLayer   = CAShapeLayer()
        
        maskLayer.path  = path.cgPath
        self.layer.mask = maskLayer
    }
    
    final override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.content
            .insetSpec(top: 0, sides: 0, bottom: safeAreaInsets.bottom)
    }
    
    override func safeAreaInsetsDidChange() {
        setNeedsLayout()
    }

}//RePopoverSheetChildContainer
