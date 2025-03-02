//
//  DismissAction.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

extension Alert {
    enum DismissAction {
        case dismiss
        case chancel
        
        var action: Action {
            switch self {
            case .dismiss:
                Action(text: "Dismiss")
            case .chancel:
                Action(text: "Chancel", style: .cancel)
            }
        }
    }
}
