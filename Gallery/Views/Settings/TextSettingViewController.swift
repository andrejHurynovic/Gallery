//
//  TextSettingViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 09.03.2025.
//

import UIKit

final class TextSettingViewController: UIViewController {
    private let action: (String) -> Void
    private var initialText: String
    
    private let titleLabel: UILabel = UILabel(font: .preferredFont(forTextStyle: .title3).withTraits(traits: .traitBold))
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        
        textView.layer.borderColor = Constants.UserInterface.borderColor.cgColor
        textView.layer.cornerRadius = Constants.UserInterface.cornerRadius
        textView.layer.borderWidth = 1
        
        textView.isScrollEnabled = false
        textView.delegate = self
        return textView
    }()
    
    private lazy var updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        
        button.setTitle("Update", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        
        button.tintColor = .systemBackground
        button.backgroundColor = .label
        
        button.layer.cornerRadius = Constants.UserInterface.cornerRadius
        
        button.addTarget(self, action: #selector(updateButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView = UIStackView(arrangedSubviews: [titleLabel, textView, updateButton])
    
    // MARK: - Initialization
    init(for setting: Setting, with initialText: String?, action: @escaping (String) -> Void) {
        self.action = action
        self.initialText = initialText ?? ""
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = setting.title
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        textView.text = initialText
        
        stackView.axis = .vertical
        stackView.spacing = Constants.UserInterface.verticalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        makeConstraints()
    }
    
    // MARK: - Layout
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor),
            
            updateButton.heightAnchor.constraint(equalToConstant: Constants.UserInterface.largeButtonSize)
        ])
    }
    
    // MARK: - Private
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func updateButtonAction() {
        initialText = textView.text
        updateButton.isEnabled = false
        action(textView.text)
    }
}

// MARK: - UITextViewDelegate
extension TextSettingViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateButton.isEnabled = textView.text != initialText
    }
}
