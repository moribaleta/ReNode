//
//  ReDropdownEntryType2.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/15/22.
//


import Foundation
import AsyncDisplayKit

/**
 * public protocol which a class or struct inherits from to be used as entries to use ReDropdownNode
 */
public protocol ReDropdownEntryType : Stringable, Hashable {
    
}

extension String : ReDropdownEntryType {
    
}
