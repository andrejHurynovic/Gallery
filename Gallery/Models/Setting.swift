//
//  Setting.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

enum Setting: Int, CaseIterable {
    case apiKey
    case cacheCount
    case clearDatabase
    
    var title: String {
        switch self {
        case .apiKey: "API Key"
        case .cacheCount: "Cache Count"
        case .clearDatabase: "Clear Database"
        }
    }
    var imageResource: ImageResource {
        switch self {
        case .apiKey: .key
        case .cacheCount: .images
        case .clearDatabase: .trash
        }
    }
    var cellType: SettingsTableViewCell.Type {
        switch self {
        case .apiKey, .cacheCount: SettingDestinationTableViewCell.self
        case .clearDatabase: SettingLabeledIconTableViewCell.self
        }
    }
}
