//
//  ToastController.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation
import UIKit
import AsyncDisplayKit
import SnapKit

/**
 * class for creating a toast notification
 */
public class Toast{
    
    static var containerView    : UIView?           = nil
    static var toastViews       : [ToastMessage]    = []
    
    class ToastMessage : UIView {
        
        var index : Int
        
        init(index: Int, backgroundColor: UIColor, textColor: UIColor, message:String, icon: Icon) {
            self.index = index
            
            super.init(frame: .zero)
            
            let messageNode     = tell(ResizeableNode()) {
                $0.backgroundColor = backgroundColor
                $0.border(radius: 20, noBorder: true)
                $0.layoutSpecBlock = {
                    _,_ -> ASLayoutSpec in
                    
                    ASLayoutSpec
                        .hStackSpec {
                            tell(ReTextNode(attributes: {
                                ReAttributedStringTraits.IconText(icon: icon, foreground: textColor)
                            })) {
                                $0.textContainerInset = .topInset(5).leftInset(5)
                                $0.frame(equal  : 24)
                                $0.border(radius: 12,
                                          color : textColor.cgColor)
                            }
                            ReTextNode(message, attribute: .titleText, color: textColor)
                                .flex(grow: 1, shrink: 1)
                        }
                        .spacing(5)
                        .justify(.center)
                        .align  (.center)
                        .insetSpec(horizontal: 10, vertical: 5)
                }
            }
            
            self.addSubnode(messageNode)
            
            messageNode.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class private func showAlert(backgroundColor: UIColor, textColor: UIColor, message:String, icon: Icon, timeout: TimeInterval, completion: CallBack.void? = nil) {
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        
        let contentWidth : CGFloat  = ((CGFloat(message.count) * 8.0) + 50.0)
        let width        : CGFloat  = contentWidth > UIScreen.main.bounds.width ? (UIScreen.main.bounds.width * 0.95) : contentWidth
        
        let index        : Int      = toastViews.count
        
        let view            = tell(ToastMessage(
                index           : index,
                backgroundColor : backgroundColor   ,
                textColor       : textColor         ,
                message         : message           ,
                icon            : icon)) {
                $0.center.x             = window.center.x
                $0.layer.masksToBounds  = true
        }
        
        if toastViews.isEmpty {
            let containerView = UIView()
            window.addSubview(
                containerView
            )
            containerView.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.top.equalToSuperview().offset(
                    UIScreen.main.safeAreaInsetZero().top
                )
            }
            self.containerView = containerView
        }
        
        self.containerView?.addSubview(view)
        
        view.transform  = .init(translationX: 0, y: -50)
        view.alpha      = 0
        
        view.snp.makeConstraints {
            make in
            make.centerX.equalToSuperview()
            if let last = self.toastViews.last {
                make.top.equalTo(last.snp.bottom).offset(5)
            } else {
                make.top.equalToSuperview().offset(5)
            }
            make.height.equalTo(40)
            make.width.equalTo(width)
        }
        toastViews.append(view)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            view.transform = .identity
            view.alpha     = 1
        }) {_ in
            UIView.animate(withDuration: 0.5, delay: timeout, animations: {
                view.alpha      = 0
                view.transform  = .init(translationX: 0, y: -50)
            }) { (_) in
                view.removeFromSuperview()
                completion?()
                toastViews.removeAll { toast in
                    toast.index == index
                }
                
                if toastViews.isEmpty {
                    self.containerView?.removeFromSuperview()
                    self.containerView = nil
                }
            }
        }
    
    }//showAlert
    
    
    ///shows green background and check icon
    public class func showPositiveMessage(message:String, timeout: TimeInterval = 3, completion: CallBack.void? = nil){
        showAlert(
            backgroundColor : Common.color.success_toast.uicolor,
            textColor       : UIColor.white,
            message         : message,
            icon            : .utilCheck,
            timeout         : timeout,
            completion      : completion
        )
    }
    
    ///shows red background and close icon
    public class func showNegativeMessage(message:String, timeout: TimeInterval = 3, completion: CallBack.void? = nil){
        showAlert(
            backgroundColor : Common.color.danger_toast.uicolor,
            textColor       : UIColor.white,
            message         : message,
            icon            : .actionClose,
            timeout         : timeout,
            completion      : completion
        )
    }

}//Toast
