//
//  SettingDestinationTableViewCell.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

import UIKit

final class SettingDestinationTableViewCell: RoundedContainerTableViewCell, SettingsTableViewCell {
    private let labeledIcon = LabeledIcon()
    private let trailingIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .chevronForward).withTintColor(Constants.UserInterface.iconColor)
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let stackView = UIStackView(arrangedSubviews: [labeledIcon, trailingIcon])
        stackView.distribution = .equalSpacing
        
        let container = RoundedContainerView(content: stackView)
        super.init(container: container, style: style, reuseIdentifier: reuseIdentifier)
        
        NSLayoutConstraint.activate([
            trailingIcon.widthAnchor.constraint(equalToConstant: Constants.UserInterface.smallIconSize)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Public
    func update(with setting: Setting) {
        labeledIcon.text = setting.title
        labeledIcon.setIcon(UIImage(resource: setting.imageResource))
    }
}
