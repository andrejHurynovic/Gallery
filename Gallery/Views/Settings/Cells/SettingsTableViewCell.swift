//
//  SettingsTableViewCell.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

import UIKit

protocol SettingsTableViewCell: UITableViewCell {
    func update(with setting: Setting)
}
