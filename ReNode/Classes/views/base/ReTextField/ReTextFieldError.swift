//
//  ReTextFieldError.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/17/22.
//

import Foundation

/// some common field error
public enum ReFieldErrorType : DisplayableError {
    public var title: String { return self.description }
    
    public var description: String {
        switch self {
        case .invalidNumber     : return "Invalid Number"
        case .required          : return "The field is required"
        case .max(let length)   : return "Field has a max length of \(length)"
        }
    }
    
    public var innerError: Error? { return nil }
    
    case invalidNumber
    case required
    case max(length: Int)
}
