//
//  SettingsNavigator.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

protocol SettingsNavigator {
    func navigateToSettingDetail(for setting: Setting, with initialText: String?, action: @escaping (String) -> Void)
    func navigateToAPIKeySetting(completion: (() -> Void)?)
    func pop()
}
