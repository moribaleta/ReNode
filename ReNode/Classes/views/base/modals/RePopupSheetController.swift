//
//  RePopupSheetController.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation
import AsyncDisplayKit
import RxSwift

open class RePopupSheetController : ASDKViewController<RePopupSheetView> {
    
    var childVC         : UIViewController!
    
    var dismissOnTap    : Bool = true
    
    var disposeBag      = DisposeBag()
    
    static func spawn(vc: UIViewController) -> RePopupSheetController {
        tell(.init(node: .init())) {
            $0.modalPresentationStyle = .overFullScreen
            $0.childVC = vc
        }
    }
    
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
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.node.viewWillDisappear()
        super.dismiss(animated: true, completion: completion)
    }
    
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.node.viewDidAppear()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.node.viewWillDisappear()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.node
            .rxTapBackground
            .filter {
                [unowned self] in
                self.dismissOnTap
            }
            .bind {
                [unowned self] in
                self.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
        
        self.node
            .rxLayoutDidChange
            .bind { [unowned self] in
                self.dismiss(animated: false)
            }.disposed(by: self.disposeBag)
    }
    
}



open class RePopupSheetView : ResizeableNode {
    
    var childViewNode   = RePopupSheetChildContainer()
    var backgroundNode  = ResizeableNode()
    
    var contentSize = CGSize.zero
    
    var rxTapBackground : Observable<Void> {
        self.emitTapBackground.asObservable()
    }
    
    var emitTapBackground = PublishSubject<Void>()
    
    var rxLayoutDidChange : Observable<Void> {
        self.emitLayoutDidChange.asObservable()
    }
    
    var emitLayoutDidChange = PublishSubject<Void>()
    
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
        self.backgroundNode.layer.opacity = 0
        self.backgroundNode.backgroundColor = .black
        let tapper = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.backgroundNode.view.addGestureRecognizer(tapper)
    }
    
    @objc func onTap() {
        self.emitTapBackground.onNext(())
        
    }
    
    func viewDidAppear() {
        self.backgroundNode.layer.opacity = 0
        UIView.animate(withDuration: 0.5) {
            self.backgroundNode.layer.opacity = 0.5
        }
    }
    
    func viewWillDisappear() {
        UIView.animate(withDuration: 0.2) {
            self.backgroundNode.layer.opacity = 0
        }
    }
    
    open override func onLayoutDidChange(prev: UIUserInterfaceSizeClass?, current: UIUserInterfaceSizeClass) {
        if prev != nil && prev != current {
            self.emitLayoutDidChange.onNext(())
        }
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.backgroundNode
            .overlaySpec {
                self.childViewNode
                    .frame(
                        minHeight: contentSize.height
                    )
                    .fraction(width: 1)
                    .relativeSpec(
                        horizontalPosition  : .start,
                        verticalPosition    : .end,
                        sizingOption        : .minimumSize
                    )
            }
    }
}




open class RePopupSheetChildContainer : BackgroundDisplay {
    
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
        self.cornerRadius       = Common.div_corner_radius
    }
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.content
            .insetSpec(10)
    }
}
