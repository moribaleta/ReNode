//
//  StateSectionList.swift
//  restate_Tests
//
//  Created by Gabriel Mori Baleta on 7/28/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation


/**
 generic class for wrapping array object for handling changes in the list
 - inherits from StateProperty
 - **T** : the type of each element in the list
 - ATTENTION:
    - the type that is passed is the type of the array
    - Example:
        ````
            class StressPropertyList<String> : StatePropertyType {{
                ...
                list = [String]()
            }
        ````
 */
public class StatePropertyList<T> : StatePropertyType, StateClearable, Equatable {
    
    public static func == (lhs: StatePropertyList<T>, rhs: StatePropertyList<T>) -> Bool {
        
        //not really used
        
        return true
    }
    
    public subscript (index: Int) -> T? {
        get {
            return self.get(index: index)
        }
        set {
            self.setElement(index: index, value: newValue!, rerender: true)
        }
    }
    
    public func getType() -> T.Type {
        return T.self
    }
    
    ///array containing the value with the object type
    public var list    = [T]()
    
    
    public init(_ list: [T]) {
        super.init()
        self.list       = list
        self.isDirty    = true
    }
    
    /**
        * getter variable
        * returns the count of elements of list
     */
    public var count : Int {
        get{
            return self.list.count
        }
    }
    
    /**
        * getter variable
        * returns a bool to determine if list is empty
     */
    public var isEmpty : Bool {
        get {
            return self.list.count <= 0
        }
    }
    
    /**
        * getter variable
        * returns a bool to determine if there are changes on the list
     */
    public var hasChanges: Bool {
        get {
            return self.changes.count > 0
        }
    }
    
    
    public override init() {
        super.init()
        self.isDirty = true
    }
    
    ///array contains all the changes made to the list
    public var changes = [StatePropertyAction<T>]()
    
    /**
        clears the arrays - changes, added, remove
        - NOTE:
            - overriden from StatePropertyType
    */
    public override func clear() {
        self.changes        = []
        self.isDirty        = false
        
        (self.list as? [StateClearable])?.forEach({ (clearable) in
            clearable.clear()
        })
    }
    
    ///sets the specific value from the list
    public func setElement(index: Int, value: T, rerender: Bool = true) {
        self.list[index] = value
        self.appendChange(type: .change, index: index, value: value, rerender: rerender)
    }
    
    ///removes the value from the list then appends StatePropertyAction with the value for reference
    public func removeElement(index: Int) -> T {
        let item = self.list.remove(at: index)
        self.appendChange(type: .remove, index: index, value: item)
        return item
    }
    
    
    @available(*, deprecated, message: "Use: addElement(value: T, index: Int? = nil)")
    ///adds an element into the list --- DEPRECATED
    public func addElement(index: Int?, value: T) {
        
        if let index = index {
            self.list.insert(value, at: index)
        }else{
            self.list.append(value)
        }

        self.appendChange(type: .add, index: index ?? self.list.count - 1 , value: value)
    }
    
    ///adds an element into the list
    public func addElement(value: T, index: Int? = nil) {
        
        if let index = index {
            self.list.insert(value, at: index)
        }else{
            self.list.append(value)
        }
        
        self.appendChange(type: .add, index: index ?? self.list.count - 1 , value: value)
    }
    
    /**
     - adds the changes to the changes array
    * Parameters:
        * type: action executed, delete, add, edit
        * index : index of the item
        * value : the value of item changed
        * rerender : determines if the change will be added to changes
            - defualt = true
    */
    public func appendChange(type: StatePropertyActionType, index: Int, value: T?, rerender: Bool = true) {
        if rerender {
            self.changes.append(StatePropertyAction(type: type, index: index , value: value, rerender: rerender))
        }
    }
    
    ///sets the value of the list
    public func setValue(_ elements: [T]) {
        self.list       = elements
        self.isDirty    = true
    }
    
    @available(*, deprecated, renamed: "setValue")
    ///sets the value of the list
    public func set(elements: [T]) {
        self.list       = elements
        self.isDirty    = true
    }
    
} //StatePropertyList

extension StatePropertyList: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(list)
        hasher.combine(isDirty)
    }
}

//helper functions for StatePropertyList
extension StatePropertyList {
    
    //ADD YOUR HELPER FUNCTION HERE
    
    /**
        returns the value by index else null
        - parameters:
            - index: Int - index of an element to be accessed
     */
    open func get(index: Int) -> T? {
        if self.list.count > index && index >= 0 && self.list.count > 0{
            return self.list[index]
        }
        return nil
    }
    
    ///contains function for determining if value exist returns the Index
    public func firstIndex(where function: ((T) throws -> Bool)) -> Int? {
        do {
            return try self.list.firstIndex(where: function)
        } catch {
            return nil
        }
    }
    
    ///function for getting the value from the list
    public func first(where function: ((T) throws -> Bool)) -> T? {
        do {
            return try self.list.first(where: function)
        } catch {
            return nil
        }
    }
    
    public func enumerated() -> [(offset: Int, element: T)] {
        return self.list.enumerated().map {(offset: $0, element: $1)}
    }
    
    ///contains function for determining if value exist on the list
    public func contains(where function: ((T) throws -> Bool)) -> Bool {
        do {
            return try self.list.contains(where: function)
        } catch {
            return false
        }
    }
    
    ///removes the element with a where function
    public func removeElement(where function: ((T) -> Bool)) -> T? {
        if let index = self.list.firstIndex(where: function) {
            return self.removeElement(index: index)
        }
        return nil
    }
    
    public func removeAll(where function: ((T)-> Bool)) -> [T] {
        let list = self.list.filter(function)
        
        self.list.removeAll(where: function)
        self.isDirty = !list.isEmpty
        
        return list
    }
    
    ///map transform function
    public func map<V>( _ function : (T) -> V ) -> [V] {
        return self.list.map(function)
    }
    
    ///filters the list
    public func filter(_ function : (T) -> Bool) -> [T] {
        return self.list.filter(function)
    }
    
    public func pop() -> T? {
        if self.list.count > 0 {
            return self.removeElement(index: self.list.count - 1)
        }
        return nil
    }
    
    ///creates a new instance with the same list
    public func copy() -> StatePropertyList<T> {
        return StatePropertyList<T>(self.list)
    }
    
    public var first : T? {
        return self.list.first
    }
    
    public var last : T? {
        return self.list.last
    }
    
}

/**
    protocol for implementing mark change to rerender selected item to rerender
    * if you dont want to implement setElement, you can use this
 */
public protocol Markable {
    func markChanged(index: Int)
}

extension StatePropertyList : Markable {
    public func markChanged(index: Int) {
        self.setElement(index: index, value: self.list[index], rerender: true)
    }
}

extension StatePropertyList where T : Markable {
    public func markChanged(indexPath: IndexPath) {
        self.markChanged(index: indexPath.section)
        self.list[indexPath.section].markChanged(index: indexPath.row)
    }
}

/**
    protocol used for identifying the type of the list as a StatePropertyList
 */
public protocol StateClearable {
    func clear()
}




///generic struct used for determining changes from the StatePropertyList
public struct StatePropertyAction<T> {
    
    ///enum used to determine the type of action made
    public var type     : StatePropertyActionType
    
    public var rerender : Bool
    
    ///the index value from the list was changed
    public var index    : Int
    
    ///contains the object that was modified - **optional**
    public var value    : T?
    
    /*
    init(type: StatePropertyActionType, index: Int, value: T?) {
        self.type   = type
        self.index  = index
        self.value  = value
    }
    */
    
    public init(type: StatePropertyActionType, index: Int, value: T?, rerender: Bool = true) {
        self.type       = type
        self.index      = index
        self.value      = value
        self.rerender   = rerender
    }
    
}//StatePropertyAction


///enum used for determining the type of action that was executed from the list
public enum StatePropertyActionType {
    case remove
    case add
    case change
}


/**
 NOTE:
    implement a generic method for 2 way binding of each component
 
    implement to set the viewcontroller to handle all local statechanges before passing it to the state
 */

/**
 stateproperty list that is for sections
 */
public class StateSectionList<T> : StatePropertyList<T> {
    
    public var sectionItem : Any?
    
}


/// maps the referenceList into a tuple with bool (reference, Bool) which is often use in selectable lists
/// - parameter referenceList: list of items being selected
/// - parameter entryList: list containing data which indicates if refernces are checked
/// - parameter isMatch: fuction to match if an object in referenceList matches an object in entryList
/// - parameter a: reference
/// - parameter b: entry
public func mapSelectionList<A, B>(referenceList: StatePropertyList<A>, entryList: StatePropertyList<B>, isMatch: (_ a: A, _ b: B) -> Bool) -> StatePropertyList<(A, Bool)> {
    
    typealias Reference = (A, Bool)
    
    let newList = referenceList.list.map { type -> Reference in
        let bool = entryList.contains(where: { isMatch(type, $0) })
        return (type, bool)
    }
    
    let newStateList = StatePropertyList<Reference>(newList)
    newStateList.isDirty = referenceList.isDirty || entryList.isDirty
    
    // copy changes of referenceList
    newStateList.changes = referenceList.changes.map { change -> StatePropertyAction<Reference> in
        
        let value = change.type == .remove
            ? (change.value == nil ? nil : (change.value!, false))
            : newList[change.index]
        
        return StatePropertyAction<Reference>(
            type: change.type,
            index: change.index,
            value: value,
            rerender: change.rerender)
    }
    
    // mark changes in newStateList for changes in entryList
    if entryList.hasChanges {
        for change in entryList.changes {
            
            guard let value = change.value else {
                continue
            }
            
            if let matchIndex = referenceList.firstIndex(where: { isMatch($0, value) }) {
                
                newStateList.markChanged(index: matchIndex)
            }
        }
    }
    
    return newStateList
}
