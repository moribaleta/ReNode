//
//  ErrorDisplayType.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit

/**
 * protocol framework for creating asdisplaynode with errors
 */
public protocol ErrorDisplayType : AnyObject {
    
    ///errors shown
    var errorLabels  : [ASTextNode] {get set}
    
    /// - parameter errors: list of error messages.
    func displayErrorMessage(_ errors: [String])
    
    /// returns border back to normal and removes error labels
    func clearErrorMessage()
}
