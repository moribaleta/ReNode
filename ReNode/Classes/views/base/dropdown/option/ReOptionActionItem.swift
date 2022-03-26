//
//  ReOptionActionItem.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation

/**
 object for displaying the title and icon of an option
 */
public struct ReOptionActionItem : ReOptionIconTextType {
    
    ///if id not provided default id is title
    public var id       : String
    public var title    : String
    public var icon     : Icon?
    public var string   : String {
        self.id
    }
    
    public init(id: String, title: String, icon: Icon? = nil) {
        self.id     = id
        self.title  = title
        self.icon   = icon
    }
    
    public init(title: String, icon: Icon? = nil) {
        self.id     = title
        self.title  = title
        self.icon   = icon
    }
}
