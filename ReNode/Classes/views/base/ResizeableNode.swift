//
//  ResizeableNode.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift

/**
 asdisplay node that reacts to layout change and orienation changes
 */
open class ResizeableNode : ASDisplayNode {
    
    var prevHorizontalClass : UIUserInterfaceSizeClass? = nil
    var prevOrientation     : UIDeviceOrientation? = nil
    var prevSize            : CGSize? = nil
    
    public var sizeClass    : UIUserInterfaceSizeClass? {
        return self.asyncTraitCollection().horizontalSizeClass
    }
    
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    open override func layoutDidFinish() {
        let current = self.asyncTraitCollection().horizontalSizeClass
        
        if prevHorizontalClass != current {
            self.onLayoutDidChange(prev: prevHorizontalClass, current: current)
            self.prevHorizontalClass = current
        }
        
        //let orientation = UIDeviceOrientation
        let currOrientation = UIDevice.current.orientation
        
        if prevOrientation != currOrientation {
            self.onOrientationDidChange(prev: prevOrientation, current: currOrientation)
            self.prevOrientation = currOrientation
        }
        
        let currSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        
        if prevSize != currSize {
            self.onLayoutSizeDidChange(prev: prevSize, current: currSize)
            self.prevSize = currSize
        }
    }
    
    ///called when previous size is changed from the current size class
    open func onLayoutDidChange(prev: UIUserInterfaceSizeClass?, current: UIUserInterfaceSizeClass){
        
    }
    
    ///called when previous orientation is change from the current orientation
    open func onOrientationDidChange(prev: UIDeviceOrientation?, current: UIDeviceOrientation){
        
    }
    
    ///called when previous size is change from the current size
    open func onLayoutSizeDidChange(prev: CGSize?, current: CGSize) {
        
    }
    
}


extension ResizeableNode {
    
    ///function for determining if view is visible from the window
    public func isViewVisible() -> Bool {
        if view.isHidden || view.superview == nil {
            return false
        }

        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController,
            let rootView = rootViewController.view {

            let viewFrame = view.convert(view.bounds, to: rootView)

            let topSafeArea: CGFloat
            let bottomSafeArea: CGFloat

            if #available(iOS 11.0, *) {
                topSafeArea = rootView.safeAreaInsets.top
                bottomSafeArea = rootView.safeAreaInsets.bottom
            } else {
                topSafeArea = rootViewController.topLayoutGuide.length
                bottomSafeArea = rootViewController.bottomLayoutGuide.length
            }

            return viewFrame.minX >= 0 &&
                   viewFrame.maxX <= rootView.bounds.width &&
                   viewFrame.minY >= topSafeArea &&
                   viewFrame.maxY <= rootView.bounds.height - bottomSafeArea
        }

        return false
    }
    
    public func willBeVisible() -> Bool {
        if view.isHidden || view.superview == nil {
            return false
        }
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController,
            let rootView = rootViewController.view {

            let viewFrame = view.convert(view.bounds, to: rootView)

            let topSafeArea: CGFloat
            let bottomSafeArea: CGFloat

            if #available(iOS 11.0, *) {
                topSafeArea = rootView.safeAreaInsets.top
                bottomSafeArea = rootView.safeAreaInsets.bottom
            } else {
                topSafeArea = rootViewController.topLayoutGuide.length
                bottomSafeArea = rootViewController.bottomLayoutGuide.length
            }
            
            let rootBounds  = rootView.bounds
            let midBounds   = viewFrame.middle.y //viewFrame.maxY - viewFrame.minY

            return  (viewFrame.minY + 100 >= topSafeArea
                    && viewFrame.minY - 100 <= rootBounds.height - bottomSafeArea) ||
                    //(midBounds + 100 >= topSafeArea && midBounds - 100 <= rootBounds.height) ||
                    (midBounds + (viewFrame.size.height / 2) >= topSafeArea && midBounds - (viewFrame.size.height / 2) <= rootBounds.height)
                    //&& viewFrame.maxY / 3 <= rootBounds.height - bottomSafeArea

            /*
            return viewFrame.minX >= 0 &&
                   viewFrame.maxX <= rootBounds.width &&
                   viewFrame.minY >= topSafeArea &&
                   viewFrame.maxY / 3 <= rootBounds.height - bottomSafeArea
            */
        }

        return false
    }

    public func rxVisible(interval : RxTimeInterval = .milliseconds(3)) -> Observable<Bool> {
        // Every second this will check `isVisibleToUser`
        return Observable<Int>.interval(interval,
                                        scheduler: MainScheduler.asyncInstance)
            .flatMap { [weak self] _ in
                return Observable.just(self?.willBeVisible() ?? false)
        }.distinctUntilChanged()
    }
    
}
