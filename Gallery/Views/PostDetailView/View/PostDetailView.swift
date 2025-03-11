//
//  PostDetailView.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 05.03.2025.
//

import UIKit

extension PostDetailViewController {
    final class View: UIView {
        private let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            return scrollView
        }()
        
        private let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = Constants.UserInterface.verticalSpacing
            stackView.layoutMargins = UIEdgeInsets(top: 0,
                                                   left: Constants.UserInterface.horizontalSpacing,
                                                   bottom: 0,
                                                   right: Constants.UserInterface.horizontalSpacing)
            stackView.isLayoutMarginsRelativeArrangement = true
            return stackView
        }()
        
        private let actionsStackView = TopStackView()
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = Constants.UserInterface.cornerRadius
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        private let infoStackView = InfoStackView()
        private let titleLabel: UILabel = UILabel(font: .preferredFont(forTextStyle: .subheadline))
        private let descriptionLabel: UILabel = {
            let label = UILabel(font: .preferredFont(forTextStyle: .subheadline).withWeight(.light))
            return label
        }()
        
        private var imageViewHeightConstraint: NSLayoutConstraint?
        
        // MARK: - Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
            makeConstraints()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
            makeConstraints()
        }
        
        // MARK: - Setup
        private func setup() {
            backgroundColor = .systemBackground
            
            addSubview(scrollView)
            scrollView.addSubview(stackView)
            stackView.addArrangedSubviews(imageView, actionsStackView, infoStackView, titleLabel, descriptionLabel)
        }
        
        // MARK: - Layout
        private func makeConstraints() {
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            // ScrollView
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            
            // StackView
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
        }
        
        // MARK: - Public
        func update(with post: any PostProtocol) {
            updateImageView(with: post)
            
            actionsStackView.update(creationDate: post.publicationDate, isFavorite: post.isPersistent)
            infoStackView.update(views: post.views, downloads: post.downloads, likes: post.likes)
            titleLabel.text = post.alternativeDescriptionText
            descriptionLabel.text = post.descriptionText
        }
        
        func updateImage(image: UIImage?) {
            guard let image = image else {
                imageView.image = nil
                return
            }
            UIView.transition(with: self, duration: Constants.animationDuration,
                              options: .transitionCrossDissolve) {
                self.imageView.image = image
            }
        }
        
        func updateActions(favoriteButtonAction: @escaping () -> Void,
                           downloadButtonAction: @escaping () -> Void) {
            actionsStackView.updateActions(favoriteButtonAction: favoriteButtonAction,
                                           downloadButtonAction: downloadButtonAction)
        }
        
        func imageViewWidth() -> CGFloat {
            return imageView.bounds.width
        }
        
        // MARK: - Private
        private func updateImageView(with post: any PostProtocol) {
            let aspectRatio = CGFloat(post.width) / CGFloat(post.height)
            imageViewHeightConstraint?.isActive = false
            imageViewHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1 / aspectRatio)
            imageViewHeightConstraint?.isActive = true
            imageView.backgroundColor = UIColor(hexadecimalColorCode: post.hexadecimalColorCode)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    PostDetailViewController(viewModel: PostsListViewModel(dataSource: .all))
}

@available(iOS 17.0, *)
#Preview {
    PostDetailViewController(viewModel: PostsListViewModel(dataSource: .favorite))
}
