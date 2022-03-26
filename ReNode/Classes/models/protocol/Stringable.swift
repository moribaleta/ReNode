//
//  Stringable.swift
//  ReNode
//
//  Created by Mini on 2/24/22.
//

import Foundation

/**
 * protocol used to represent any object as a string
 * this is also  used in navigationstateprotocol to identify a state
 */
public protocol Stringable {
    var string : String { get }
}

extension String : Stringable {
    public var string: String {
        return self
    }
}

