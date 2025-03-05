//
//  PhotoViewCell.swift
//  UIKitLearning
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import UIKit

final class PhotoViewCell: UICollectionViewCell {
    @Injected var dataService: (any DataServiceProtocol)?
    
    private let imageView = UIImageView()
    private var imageTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageView.image = nil
    }
    
    // MARK: - Setup
    
    private func setup() {
        layer.cornerRadius = 10
        setupImageView()
    }
    
    private func setupImageView() {
        imageView.layer.cornerRadius = 10
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Public methods
    
    func update(with photo: any PhotoProtocol) {
        backgroundColor = UIColor(hexadecimalColorCode: photo.hexadecimalColorCode)
        addImageUpdateTask(with: photo)
    }
    
    // MARK: - Private methods
    
    private func addImageUpdateTask(with photo: any PhotoProtocol) {
        imageTask = Task {
            guard Task.isCancelled == false,
                  let imageBox = await dataService?.scaledImage(for: requirements(for: photo)),
                  let image = imageBox.image as? UIImage else { return }
            await MainActor.run {
                UIView.transition(with: self, duration: 0.3,
                                  options: .transitionCrossDissolve) {
                    self.imageView.image = image
                }
            }
        }
    }
    
    private func requirements(for photo: any PhotoProtocol) -> ImageRequirements {
        ImageRequirements(id: photo.id,
                          imageURL: photo.imageURL,
                          requiredWidth: bounds.width,
                          requiredHeight: bounds.height)
    }
}
