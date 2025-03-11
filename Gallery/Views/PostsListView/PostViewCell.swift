//
//  PostViewCell.swift
//  UIKitLearning
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import UIKit

final class PostViewCell: UICollectionViewCell {
    var viewModel: PostsListViewModel!
    
    private let imageView = UIImageView()
    private let favoriteIconImageView = UIImageView()
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
        layer.cornerRadius = Constants.UserInterface.cornerRadius
        setupImageView()
        setupFavoriteIconImageView()
    }
    
    private func setupFavoriteIconImageView() {
        favoriteIconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(favoriteIconImageView)
        NSLayoutConstraint.activate([
            favoriteIconImageView.heightAnchor.constraint(equalToConstant: Constants.UserInterface.smallIconSize),
            favoriteIconImageView.widthAnchor.constraint(equalToConstant: Constants.UserInterface.smallIconSize),
            favoriteIconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            favoriteIconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
    
    private func setupImageView() {
        imageView.layer.cornerRadius = Constants.UserInterface.cornerRadius
        
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
    
    // MARK: - Public
    func update(with post: any PostProtocol, index: Int) {
        backgroundColor = UIColor(hexadecimalColorCode: post.hexadecimalColorCode)
        favoriteIconImageView.image = UIImage(resource: post.isPersistent ? .favoriteFilled : .favorite).withTintColor(.white)
        addImageUpdateTask(for: index)
    }
    
    // MARK: - Private
    private func addImageUpdateTask(for index: Int) {
        imageTask = Task {
            guard Task.isCancelled == false,
                  let imageBox = await viewModel.getImage(for: index, with: bounds.size),
                  let image = imageBox.image as? UIImage else { return }
            await MainActor.run {
                UIView.transition(with: self, duration: Constants.animationDuration,
                                  options: .transitionCrossDissolve) {
                    self.imageView.image = image
                }
            }
        }
    }
}
