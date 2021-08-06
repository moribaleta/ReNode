//
//  String.swift
//  
//
//  Created by Gabriel Mori Baleta on 8/6/21.
//

import Foundation


extension String {
    
    public func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    public func split(separator: String) -> [String] {
        // return self.characters.split(separator: separator).map(String.init)
        return self.components(separatedBy: separator)
    }
    
    public func substring(start: Int = 0, end: Int) -> String {
        let startIndex  = self.index(self.startIndex, offsetBy: start)
        let endIndex    = self.index(self.startIndex, offsetBy: end)
        return String(self[startIndex..<endIndex])
    }
    
    public func substring(fromOffset offset: Int) -> String {
        guard offset < self.count else {
            return ""
        }
        //return self.substring(from: self.index(self.startIndex, offsetBy: offset))
        return String(self.prefix(offset))
    }
    
    public static func isNilOrEmpty(val: String?) -> Bool {
        return (val ?? "").trim().isEmpty
    }
    
    /**
     Returns true if the input string follows a valid email format.
     - Parameter val: The email.
     - Returns: true if valid, or if the string is empty.
     */
    public static func isEmailOkay(val: String) -> Bool {
        let emailRegEx      = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest       = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let emailOkay       = val.trim().isEmpty == false
            ? emailTest.evaluate(with: val)
            : true
        
        return emailOkay
    }
    
    
    public func appendPath(component: String) -> String {
        
        return (self as NSString).appendingPathComponent(component)
    }
    
    
    public func urlEncoded() -> String {
        return self.replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: "?", with: "%3F")
            .replacingOccurrences(of: "&", with: "%26")
    }
    
    
    
    
    public func numberOnly() -> String {
        let stringArray = self.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
        let newString = stringArray.joined(separator: "")
        
        return newString
    }
    
    public func isPhoneNumber() -> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    
    
    public func removePrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return String(self.dropFirst(prefix.count))
        }
        return self
    }
    
    public func removeSuffix(_ suffix: String) -> String {
        if self.hasSuffix(suffix) {
            return String(self.dropLast(suffix.count))
        }
        return self
    }
    
    ///used to determine if string has value, whitespace are trimmed
    public var hasValue : Bool {
        return !(self.trim().isEmpty)
    }
    
    ///used to determine if string has no value, whitespace are trimmed
    public var hasNoValue : Bool {
        return self.trim().isEmpty
    }
    
    var numberOfLines : Int {
        return self.numberOfOccurrencesOf(string: "\n") + 1
    }
    
    func numberOfOccurrencesOf(string: String) -> Int {
        return self.components(separatedBy:string).count - 1
    }
}


//infix operator ??! {
//    associativity right
//    precedence 10
//}

infix operator ??! : coalesceEmpty

precedencegroup coalesceEmpty {
    associativity: right
    higherThan: ComparisonPrecedence
    lowerThan: NilCoalescingPrecedence
}

/// nil or empty string coalescing: returns right-hand-side if left-hand-side is nil or empty.
public func ??! (lhs: String?, rhs: String) -> String {
    return (lhs ?? "").isEmpty ? rhs : lhs!
}


public extension Optional where Wrapped == String {
 
    var hasValue : Bool {
        self?.hasValue ?? false
    }
    
    var hasNoValue : Bool {
        self?.hasNoValue ?? true
    }
    
}
