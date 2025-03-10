//
//  SettingLabeledIconTableViewCell.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

import UIKit

final class SettingLabeledIconTableViewCell: RoundedContainerTableViewCell, SettingsTableViewCell {
    let labeledIcon = LabeledIcon(font: .preferredFont(forTextStyle: .body),
                                  color: .systemBackground)
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let container = RoundedContainerView(content: labeledIcon, color: .label, isFilled: true)
        super.init(container: container, style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Public
    func update(with setting: Setting) {
        labeledIcon.setIcon(UIImage(resource: setting.imageResource))
        labeledIcon.text = setting.title
    }
}
