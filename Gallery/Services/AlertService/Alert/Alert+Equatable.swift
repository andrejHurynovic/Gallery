//
//  Alert+Equatable.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 02.03.2025.
//

extension Alert: Equatable {
    static func == (lhs: Alert, rhs: Alert) -> Bool {
        return lhs.title == rhs.title &&
        lhs.message == rhs.message &&
        lhs.actions.count == rhs.actions.count
    }
}
