//
//  ReModalType.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation


public protocol ReModalType : AnyObject {
    var navigation : UINavigationController {get set}
    func dismiss(_ animated: Bool)
}


public extension UIViewController {
    
    ///dismisses the modal based on if the modal is inside a ReModalType or just a basic modal
    func onClose() {
        if let modal = self.reModalType { //self.floatSheet {
            modal.dismiss(true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    ///returns the based parent as ReModalType
    var reModalType : ReModalType? {
        var vcToCheck : UIViewController? = self
        
        while (true) {
            if (vcToCheck == nil) {
                return nil
            } else if vcToCheck is ReModalType {
                return vcToCheck as? ReModalType
            } else {
                vcToCheck = vcToCheck?.parent
            }
        }
    }//reModalType
    
}//public extension UIViewController
