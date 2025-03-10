//
//  RoundedContainerView.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

final class RoundedContainerView: UIView {
    private let cornerStyle: CornerStyle
    private let color: UIColor
    
    // MARK: - Initialization
    init(content: UIView,
         cornerStyle: CornerStyle = .fixed(Constants.UserInterface.cornerRadius),
         color: UIColor = Constants.UserInterface.borderColor,
         isFilled: Bool = false) {
        self.cornerStyle = cornerStyle
        self.color = color
        
        super.init(frame: .null)
        if isFilled {
            backgroundColor = color
        } else {
            backgroundColor = .systemBackground
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
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        switch cornerStyle {
        case let .fixed(radius):
            layer.cornerRadius = radius
        case .circle:
            layer.cornerRadius = bounds.width / 2
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.borderColor = color.cgColor
        }
    }
}

extension RoundedContainerView {
    enum CornerStyle {
        case fixed(CGFloat)
        case circle
    }
}
