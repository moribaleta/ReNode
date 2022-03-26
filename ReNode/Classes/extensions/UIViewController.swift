//
//  UIViewController.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation


public extension UIViewController {
    
    func presentPopup(
        vc          : UIViewController,
        peg         : UIView,
        animated    : Bool = true,
        completion  : CallBack.void? = nil
    ) {
        
        let popover = RePopoverSheetController.spawn(vc: vc, peg: peg)
        self.present(
            popover,
            animated    : animated,
            completion  : completion
        )
    }
    
}



public extension UIApplication {
    
    var isKeyboardPresented: Bool {
        guard let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow") else { return false };
        return UIApplication.shared.windows.contains(where: { $0.isKind(of: keyboardWindowClass) })
    }
    
    func dismissKeyboard() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    var sizeClass : UIUserInterfaceSizeClass? {
        return UIApplication.shared.rootView?.traitCollection.horizontalSizeClass
    }
    
    var rootView : UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    var isSplitOrSlideOver: Bool {
        guard let w = self.delegate?.window, let window = w else { return false }
        return !window.frame.equalTo(window.screen.bounds)
    }
    
    func topMostController(_ base : UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topMostController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topMostController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topMostController(presented)
        }
        return base
    }
}

