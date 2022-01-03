//
//  Sequence.swift
//  
//
//  Created by Gabriel Mori Baleta on 12/22/21.
//

import Foundation
import UIKit
import RxSwift

// Updated for Swift 3.0
public protocol OptionalType {
    associatedtype Wrapped
    func map<U>(_ f: (Wrapped) throws -> U) rethrows -> U?
}

extension Optional: OptionalType {}

public extension Sequence where Iterator.Element: OptionalType {
    
    /**
     Removes nil values from the array.
     - See also: asdf
     - Parameter array: The array to filter from.
     - Returns: A filtered array, containing only unwrapped values.
     */
    public func filterNils() -> [Iterator.Element.Wrapped] {
        var result: [Iterator.Element.Wrapped] = []
        for element in self {
            if let element = element.map({ $0 }) {
                result.append(element)
            }
        }
        return result
    }
}

public extension Sequence where Iterator.Element == String {
    
    /**
     Removes empty strings from the array.
     - Parameter array: The string array to filter from.
     - Returns: A filtered string array, containing only non-empty string values.
     */
    public func filterEmpty() -> [Iterator.Element] {
        return self.filter({ $0.isEmpty == false })
    }
}


public extension Sequence {
    
    public func categorise<U : Hashable>(_ key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = key(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
    
    public func toDictionary<U : Hashable>(_ key: (Iterator.Element) -> U) -> [U : Iterator.Element] {
        var dict : [U : Iterator.Element] = [:]
        for el in self {
            let key = key(el)
            dict[key] = el
        }
        return dict
    }
}


