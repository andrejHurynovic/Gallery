//
//  ImageButton.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

class ImageButton: UIButton {
    var action: (() -> Void)?
    
    // MARK: - Initialization
    
    init(image: UIImage? = nil, action: (() -> Void)? = nil) {
        self.action = action
        super.init(frame: .zero)
        setupButton(image: image)
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustImageInsets()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Private
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image?.withTintColor(.label), for: state)
    }
    
    private func setupButton(image: UIImage?) {
        self.setImage(image, for: .normal)
        self.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    private func adjustImageInsets() {
        self.imageView?.contentMode = .scaleAspectFit
        let inset = (bounds.height - Constants.UserInterface.largeIconSize) / 2
        self.imageEdgeInsets = .init(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    @objc func buttonAction() {
        action?()
    }
}
