//
//  UIScreen.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 2/22/22.
//

import Foundation
import UIKit

public extension UIScreen {
    
    ///returns safe area inset of rootview
    func safeAreaInset() -> UIEdgeInsets? {
        guard let rootview = UIApplication.shared.keyWindow else {return nil}
        
        if #available(iOS 11.0, *) {
            return rootview.safeAreaInsets
        } else {
            return rootview.layoutMargins
        }
    }
    
    func isPortrait() -> Bool? {
        return UIScreen.main.bounds.height > UIScreen.main.bounds.width
    }
    
    ///returns safe area inset of rootview
    func safeAreaInset(minVertical: CGFloat = 0, minHorizontal: CGFloat = 0) -> UIEdgeInsets {
        
        var inset : UIEdgeInsets!
        
        if let rootview = UIApplication.shared.keyWindow {
            if #available(iOS 11.0, *) {
                inset = rootview.safeAreaInsets
            } else {
                inset = rootview.layoutMargins
            }
        } else {
            inset = .zero
        }
        
        if inset.top < minVertical {
            inset.top = minVertical
        }
        if inset.bottom < minVertical {
            inset.bottom = minVertical
        }
        if inset.right < minHorizontal {
            inset.right = minHorizontal
        }
        if inset.left < minHorizontal {
            inset.left = minHorizontal
        }
        
        return inset
    }
    
    func safeAreaInsetZero() -> UIEdgeInsets {
        return self.safeAreaInset(top: 0, sides: 0, bottom: 0)
    }
    
    ///returns safe area inset of rootview
    func safeAreaInset(top: CGFloat = 0, sides: CGFloat = 0, bottom: CGFloat = 0) -> UIEdgeInsets {
        
        var inset : UIEdgeInsets!
        
        if let rootview = UIApplication.shared.keyWindow {
            if #available(iOS 11.0, *) {
                inset = rootview.safeAreaInsets
            } else {
                inset = rootview.layoutMargins
            }
        } else {
            inset = .zero
        }
        
        if inset.top < top {
            inset.top = top
        }
        if inset.bottom < bottom {
            inset.bottom = bottom
        }
        if inset.right < sides {
            inset.right = sides
        }
        if inset.left < sides {
            inset.left = sides
        }
        
        return inset
    }
}


