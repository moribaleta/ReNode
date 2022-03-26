//
//  ProgressiveViewProtocol.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import AsyncDisplayKit

///protocol used to define the class to be progrssively loaded
public protocol ProgressiveViewProtocol {
    
    ///used to determine if the component was loaded
    var isViewed        : Bool {get set}
    
    ///placeholder display
    var loader          : ASDisplayNode? {get set}
    
    ///interval time to check if the view was displayed on the viewport
    var interval_time   : RxTimeInterval {get set}
    
    ///function called to do any operation after the view was visible
    func onDidViewVisible()
    
    ///function to return the layout after the view was loaded, alternative to using layoutSpecThatFits
    func layoutContent(_ constrainedSize: ASSizeRange) -> ASLayoutSpec

}//ProgressiveViewProtocol



