//
//  SettingsViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

import UIKit

final class SettingsViewController: UIViewController {
    private let viewModel: SettingsViewModel
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SettingLabeledIconTableViewCell.self, forCellReuseIdentifier: SettingLabeledIconTableViewCell.defaultReuseIdentifier)
        tableView.register(SettingDestinationTableViewCell.self, forCellReuseIdentifier: SettingDestinationTableViewCell.defaultReuseIdentifier)
        
        tableView.rowHeight = Constants.UserInterface.largeButtonSize + Constants.UserInterface.verticalSpacing
        return tableView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationItem()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        makeConstraints()
    }
    
    // MARK: - Setup
    private func setupNavigationItem() {
        self.title = "Settings"
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))]
    }
    
    // MARK: - Layout
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Private
    @objc private func close() {
        dismiss(animated: true)
    }
}

// MARK: - Delegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let setting = Setting(rawValue: indexPath.row) else { return }
        viewModel.performAction(for: setting)
    }
}

// MARK: - DataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Setting.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let setting = Setting(rawValue: indexPath.row),
              let cell = tableView.dequeueReusableCell(withIdentifier: setting.cellType.defaultReuseIdentifier, for: indexPath) as? SettingsTableViewCell  else {
            return UITableViewCell()
        }
        
        cell.update(with: setting)
        return cell
    }
}
