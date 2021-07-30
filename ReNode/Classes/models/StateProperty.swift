//
//  StateProperty.swift
//  SMDModuleUtility
//
//  Created by Gabriel on 12/07/2019.
//  Copyright © 2019 Leapfroggr Inc. All rights reserved.
//

import Foundation

/**
 generic class for wrapping the variables in ReducerState
 */
public class StatePropertyType: StateClearable {
    ///determines whether  the object has changed
    public var isDirty : Bool = false
    
    /**
     - clears the changes of the object
     - ATTENTION: override this function
     */
    @available(*, deprecated, renamed: "clearFlag")
    public func clear () {
        
    }
    
    /**
     - clears the changes of the object
     - ATTENTION: override this function
     */
    public func clearFlag () {
        
    }
}

/**
 generic class for wrapping the variables in ReducerState
 */
public class StateProperty<T> : StatePropertyType {
    
    /**
     - contains the value of the StateProperty
     - calls didSet on change value
     */
    private var _object : T?
    
    public var object : T? {
        get {
            return self._object
        }
        set (newObject) {
            isDirty = true
            _object = newObject
        }
    }
    
    public override init() {
        super.init()
        self.isDirty = true
    }
    
    public convenience init(_ value: T?) {
        self.init()
        self.object = value
    }
    
    public func set(_ object : T?) {
        self.object = object
    }
    
    ///determins if the object is empty/null
    public var isEmpty : Bool {
        return self.object == nil
    }
    
    public override func clear() {
        self.isDirty = false
    }
    
    public override func clearFlag() {
        self.isDirty = false
    }
    
    //....
    
}//StateProperty

