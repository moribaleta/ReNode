//
//  UIEdgeInsets.swift
//  SampleApp
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//

import Foundation
import UIKit
import RxSwift

extension UIEdgeInsets {

    public init(all value: CGFloat) {

        self.init(top: value, left: value, bottom: value, right: value)
    }

    public init(top t: CGFloat, sides s: CGFloat, bottom b: CGFloat) {

        self.init(top: t, left: s, bottom: b, right: s)
    }

    public init(horizontal h: CGFloat, vertical v: CGFloat) {

        self.init(top: v, left: h, bottom: v, right: h)
    }
}

public extension CGRect {

    var middle: CGPoint { return .init(x: midX, y: midY) }

    var bounds: CGRect  { return .init(origin: .zero, size: size) }
}



import RxSwift


/// If a descriptive error is meant to be displayed to the user
public protocol DisplayableError : DescriptiveError {
    
}

/// Error with more comprehensive description to help debug
public protocol DescriptiveError : Error {
    
    /**
     The title to be displayed, when shown on a `UIAlertController`.
     */
    var title       : String { get }
    
    /**
     The description text to be displayed, when shown on a `UIAlertController`.
     */
    var description : String { get }
    
    /**
     An optional inner error that can be used to wrap an error.
     */
    var innerError  : Error? { get }
}

public extension DescriptiveError {
    var debugMessage: String {
        get {
            
            if let inner = innerError {
                
                if let displayable = inner as? DisplayableError {
                    return "\(self.title): \(self.description)\n"
                        + displayable.debugMessage
                } else {
                    return "\(self.title): \(self.description)\n"
                        + "\(inner): \(inner.localizedDescription)"
                }
                
            }
            
            return "\(self.title): \(self.description)"
            
        }
    }
}

public enum SerializationError : Error {
    case failed
    case unknown (data: Any?)
}

public enum ParseError : Error {
    case keyNotFound(key: String)
    case castFailed(key: String)
    case unknown(message: String)
    
    var description : String {
        switch self {
        case .keyNotFound(let key):
            return "ParseError. Key '\(key)' not found."
        case .castFailed(let key):
            return "While attempting to parse key \(key), the expected data type could not be acquired."
        case .unknown(let message):
            return "Unknown Parse Error. \(message)"
        default:
            return "TBD"
        }
    }
}


public enum AppError : Error {
    case outdated
}

// Convenient Descriptive Error class if too lazy or general to define one
public class DescriptionError : DescriptiveError {
    public var _title       : String?
    public var _description : String?
    public var _innerError  : Error?
    
    
    public init() { }
    
    public convenience init(title: String?, description: String?, innerError: Error? = nil) {
        self.init()
        self._title = title
        self._description = description
        self._innerError = innerError
    }
    
    public var title       : String { get { return _title       ?? "--" } }
    public var description : String { get { return _description ?? "--" } }
    public var innerError  : Error? { get { return _innerError          } }
}

// Convenient Displayable Error class if too lazy or general to define one
public class SimpleError: DescriptionError, DisplayableError {
    
    public override init() {
        super.init()
    }
    
    public init(title: String, description: String, error: Error? = nil) {
        super.init()
        self._title = title
        self._description = description
        self._innerError = error
    }

    public static func create(title: String, description: String) -> SimpleError {
        let err = SimpleError()
        err._title = title
        err._description = description
        return err
    }
}


public extension Observable {
    func wrapError(title: String, message: String) -> Observable<Element> {
        return self.catch { (error: Error) -> Observable<Element> in
            let e = DescriptionError()
            e._title = title
            e._description = message
            e._innerError = error
            return .error(e)
        }
    }
}

public extension Error {
    func describe() -> String {
        if let display = self as? DescriptiveError {
            return [
                "\(display.title): \(display.description)",
                display.innerError?.describe() ?? ""
            ]
            .filter({ $0.isEmpty == false })
            .joined(separator: "\n")
            
        //} else if let nserror = self as? NSError {
        //    return "\(self): \(nserror)"
        } else {
            return "\(self): \(self.localizedDescription)"
        }
    }
    
    /// check if self or inner errors contains Specific error type
    func cast<E: Error>() -> E? {
        if let instance = self as? E {
            return instance
        } else if let display = self as? DescriptiveError {
            if let innerError = display.innerError {
                return innerError.cast()
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func displayableError() -> DisplayableError? {
        if let instance = self as? DisplayableError {
            return instance
        } else if let display = self as? DescriptiveError {
            if let innerError = display.innerError {
                return innerError.displayableError()
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
