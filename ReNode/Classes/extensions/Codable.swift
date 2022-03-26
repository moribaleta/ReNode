//
//  Codable.swift
//  ReNode
//
//  Created by Mini on 3/12/22.
//

import Foundation

public func decode<E>(json: String) -> E? where E : Codable {
    let model : E? = try? JSONDecoder().decode(E.self, from: json.data(using: .utf8)!)
    return model
}
