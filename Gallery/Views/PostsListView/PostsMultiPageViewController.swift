//
//  PostsMultiPageViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 11.03.2025.
//

import UIKit

final class PostsMultiPageViewController: MultiPageViewController {
    private let settingsTitle = "Settings"
    
    private let viewModel: PostsMultiPageViewModel
    
    // MARK: - Initialization
    init(viewModel: PostsMultiPageViewModel) {
        self.viewModel = viewModel
        super.init(pages: [
            PostsListViewController(viewModel: PostsListViewModel(dataSource: .all)),
            PostsListViewController(viewModel: PostsListViewModel(dataSource: .favorite))
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Public
    override func getTitles(for index: Int) -> (currentTitle: String?, nextTitle: String?, upcomingTitle: String?) {
        var titles = super.getTitles(for: index)
        switch index {
        case 0: titles.upcomingTitle = settingsTitle
        case 1: titles.nextTitle = settingsTitle
        default: break
        }
        return titles
    }
    
    override func setNextPage(for index: Int?) {
        super.setNextPage(for: index)
        if index == 1 {
            viewModel.navigateToSettings()
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    let navigationController = UINavigationController()
    let viewModel = PostsMultiPageViewModel(applicationNavigator: ApplicationCoordinator(with: navigationController))
    let viewController = PostsMultiPageViewController(viewModel: viewModel)
    navigationController.pushViewController(viewController, animated: false)
    return navigationController
}
