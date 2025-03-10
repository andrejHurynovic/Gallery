//
//  RoundedContainerTableViewCell.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

import UIKit

class RoundedContainerTableViewCell: UITableViewCell {
    init(container: RoundedContainerView, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.UserInterface.horizontalSpacing)
        ])
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) { super.init(style: style, reuseIdentifier: reuseIdentifier) }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
