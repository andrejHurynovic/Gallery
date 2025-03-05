//
//  RoundedContainerView.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

final class RoundedContainerView: UIView {
    init(content: UIView, color: UIColor = UIColor.quaternaryLabel, isFilled: Bool = false) {
        super.init(frame: .null)
        layer.cornerRadius = Constants.UserInterface.cornerRadius
        if isFilled {
            backgroundColor = color
        } else {
            layer.borderWidth = 1
            layer.borderColor = color.cgColor
        }
        
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
