//
//  FavoriteButton.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

final class FavoriteButton: ImageButton {
    var isFavorite: Bool = false {
        didSet { updateImage() }
    }
    
    // MARK: - Initialization
    init(action: (() -> Void)? = nil) {
        super.init(action: action)
        updateImage()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Private
    private func updateImage() {
        let image = isFavorite ? UIImage(resource: .favoriteFilled) : UIImage(resource: .favorite)
        self.setImage(image, for: .normal)
    }
    
    @objc override func buttonAction() {
        super.buttonAction()
        isFavorite.toggle()
    }
}
