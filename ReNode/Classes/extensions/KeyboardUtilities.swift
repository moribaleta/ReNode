//
//  KeyboardUtilities.swift
//  SMDModuleUtility
//
//  Created by Gabriel Mori Baleta on 5/3/21.
//  Copyright © 2021 Leapfroggr Inc. All rights reserved.
//

import Foundation
import RxKeyboard
import RxSwift

/**
 wrapper for rxKeyboard
 */
public class KeyboardUtilities {
    
    ///static instance
    public static var instance  = KeyboardUtilities()
    
    ///obs for subscribing to keyboard props
    public var rxKeyboard   : Observable<KeyboardProps>{
        return self.emitKeyboard.asObservable()
    }
    
    private var emitKeyboard    = PublishSubject<KeyboardProps>()
    var disposeBag              = DisposeBag()
    
    public var props            = KeyboardProps()
    
    public struct KeyboardProps {
        public var height      : CGFloat   = 0
        public var isFloating  : Bool      = false
        public var frame       : CGRect    = .zero
        
        public static var empty : KeyboardProps {
            .init()
        }
        
        public init(
            height      : CGFloat   = 0,
            isFloating  : Bool      = false,
            frame       : CGRect    = .zero
        ){
            self.height     = height
            self.isFloating = isFloating
            self.frame      = frame
        }
    }
    
    init() {
        
        Observable.merge(
            NotificationCenter.default.rx.notification(UIApplication.keyboardWillShowNotification),
            NotificationCenter.default.rx.notification(UIApplication.keyboardWillHideNotification),
            NotificationCenter.default.rx.notification(UIApplication.keyboardWillChangeFrameNotification))
            .map        { notification in
                
                let endFrame    = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect

                let screen      = UIScreen.main.bounds
                let docked      = screen.maxX == endFrame?.maxX && screen.maxY == endFrame?.maxY && screen.width == endFrame?.width
                
                let height      : CGFloat
                
                if docked {
                    height = UIScreen.main.bounds.height - endFrame!.minY
                } else {
                    height = 0
                }
                
                let maxHeight = height - (UIDevice.current.userInterfaceIdiom == .phone ? 0 : UIScreen.main.safeAreaInsetZero().bottom)
                
                //return KeyboardProps(height: max(0, height - UIApplication.shared.rootView!.view.safeAreaInsets.bottom), isFloating: !docked, frame: endFrame!)
                return KeyboardProps(height: max(0, maxHeight),
                                     isFloating: !docked, frame: endFrame!)
            }
            .bind       (to: emitKeyboard)
            .disposed   (by: disposeBag)
    }

    public func trigger() {
        self.emitKeyboard.onNext(self.props)
    }
}//KeyboardUtilities
