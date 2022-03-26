//
//  ReOptionActionType.swift
//  ReNode
//
//  Created by Gabriel Mori Baleta on 3/24/22.
//

import Foundation


public protocol ReOptionIconTextType : ReDropdownEntryType {
    var icon  : Icon?  {get}
    var title : String {get}
}

/**
 enum for displaying action in more option button on popup
 */
public enum ReOptionActionType : ReOptionIconTextType {

    public var string: String {
        self.title
    }
    
    public static let finalize = "Finalize Note"
    public static let sendToPatient = "Send to Patient"
    
    
    case edit
    case delete
    case add
    case complete
    case print
    case preview
    case download
    case search
    case copy
    case document
    case share(peg: UIView)
    case other(icon: Icon, title: String)
    
    
    public var icon : Icon? {
        switch self {
        case .edit:
            return .actionEdit
        case .delete:
            return .actionDelete
        case .add:
            return .actionAdd
        case .complete:
            return .queueComplete
        case .print:
            return .actionPrint
        case .download:
            return .actionDownload
        case .search:
            return .actionSearch
        case .copy:
            return .notes
        case .document:
            return .actionShow
        case .preview:
            return .utilInfo
        case .share( _):
            return .actionShare
        
        case .other(let othericon, _):
            return othericon
        }
    }
    
    public var title : String {
        switch self {
        case .edit:
            return "Edit"
        case .delete:
            return "Delete"
        case .add:
            return "Add"
        case .complete:
            return "Complete"
        case .print:
            return "Print"
        case .download:
            return "Download"
        case .search:
            return "Search"
        case .copy:
            return "Copy"
        case .document:
            return "Open"
        case .preview:
            return "Preview"
        case .share(_):
            return "Share"
        case .other( _, let othername):
            return othername
        }
    }
    
    public static var EDIT_ACTIONS : [ReOptionActionType] {
        return [.edit, .delete]
    }
    
    public static var CRUD_ACTIONS : [ReOptionActionType] {
        return [.add, .edit, .delete]
    }
    
    var item : ReOptionActionItem {
        return ReOptionActionItem(id: "\(self)", title: self.title, icon: self.icon)
    }
    
}//OptionActionType

public func == (lhs : ReOptionActionItem, rhs : ReOptionActionItem) -> Bool
{
    return lhs.icon == rhs.icon && lhs.id == rhs.id && lhs.title == rhs.title
}

public func == (lhs : ReOptionActionType, rhs : ReOptionActionType) -> Bool
{
    return lhs.item == rhs.item
}
