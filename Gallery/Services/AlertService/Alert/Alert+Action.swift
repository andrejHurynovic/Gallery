//
//  Action.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import UIKit

extension Alert {
    struct Action {
        let text: String
        let style: UIAlertAction.Style
        
        let action: (() -> Void)?
        
        init(text: String,
             style: UIAlertAction.Style = .default,
             action: (() -> Void)? = nil) {
            self.text = text
            self.style = style
            self.action = action
        }
    }
}
