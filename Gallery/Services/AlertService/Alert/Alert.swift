//
//  Alert.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 02.03.2025.
//

import UIKit

struct Alert {    
    let title: String
    let message: String?
    let actions: [Action]
    
    init(title: String,
         message: String? = nil,
         actions: Action...,
         defaultDismissAction: DismissAction? = .dismiss) {
        self.title = title
        self.message = message
        
        if let defaultDismissAction {
            self.actions = actions + [defaultDismissAction.action]
        } else {
            self.actions = actions
        }
    }
}
