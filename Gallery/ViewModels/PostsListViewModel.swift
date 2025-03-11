//
//  PostsListViewModel.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import UIKit
import Combine

final class PostsListViewModel {
    @Injected private var alertService: (any AlertServiceProtocol)?
    @Injected private var dataService: (any DataServiceProtocol)?
    @Injected private var networkService: (any NetworkServiceProtocol)?
    
    private var posts: [any PostProtocol] = []
    var postsCount: Int { posts.count }
    var postsUpdatesPublisher = PassthroughSubject<(indexes: [Int]?, count: Int?, removedIndex: Int?), Never>()
    
    let dataSource: DataSource
    
    private var awaitingForContent: Bool = false
    private var nothingToFetch: Bool = false
    private var targetElementsCount = Constants.postsFetchPageSize
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: - Public
    
    func startMonitor() {
        addSubscriptions()
        fetchMoreContentIfNeeded()
    }
    
    func fetchMoreContentIfNeeded(for itemIndex: Int? = nil) {
        if let itemIndex {
            targetElementsCount = max(targetElementsCount, itemIndex + Constants.imageFetchThreshold)
        }
        guard !nothingToFetch,
              !awaitingForContent,
              posts.count < targetElementsCount else { return }
        fetchMoreContent()
    }
    
    func post(for index: Int) -> (any PostProtocol)? {
        fetchMoreContentIfNeeded(for: index)
        guard index < posts.count else { return nil }
        return posts[index]
    }
    
    func getImage(for index: Int, with size: CGSize) async -> (any ImageBoxProtocol)? {
        guard index < posts.count else { return nil }
        guard let image = await dataService?.scaledImage(for: posts[index], with: size) else { return nil }
        return image
    }
    
    func downloadImage(for index: Int) {
        guard index < posts.count else { return }
        let post = posts[index]
        
        Task {
            await alertService?.showAlert(imageSaveConfirmationAlert(for: post))
        }
    }
    
    func updatePost(for index: Int) async {
        guard index < posts.count else { return }
        let post = posts[index]
        await dataService?.updatePost(post: post)
    }
    
    func toggleFavorite(for index: Int) {
        guard index < posts.count else { return }
        let post = self.posts[index]
        Task { [weak dataService] in
            await dataService?.changePersistenceStatus(for: post, to: !post.isPersistent)
        }
    }
    
    // MARK: - Private
    private func addSubscriptions() {
        networkService?.networkAvailablyPublisher.sink { [weak self] isAvailable in
            if isAvailable == true {
                self?.fetchMoreContentIfNeeded()
            }
        }
        .store(in: &cancellables)
        Task {
            await dataService?.postsUpdatePublisher
                .sink { [weak self] in
                    self?.replacePost(post: $0)
                }
                .store(in: &cancellables)
        }
        
    }
    
    private func replacePost(post: any PostProtocol) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            foundIndex(index)
        } else if dataSource == .favorite {
            posts.insert(post, at: 0)
            postsUpdatesPublisher.send((indexes: [0], count: posts.count, removedIndex: nil))
        }
        
        func foundIndex(_ index: Int) {
            switch dataSource {
            case .all:
                posts[index] = post
                postsUpdatesPublisher.send((indexes: [index], count: nil, removedIndex: nil))
            case .favorite:
                if post.isPersistent {
                    posts[index] = post
                    postsUpdatesPublisher.send((indexes: [index], count: nil, removedIndex: nil))
                } else {
                    posts.remove(at: index)
                    postsUpdatesPublisher.send((indexes: nil, count: posts.count, removedIndex: index))
                }
            }
        }
    }
    
    private func fetchMoreContent() {
        Task { [weak self] in
            defer { self?.awaitingForContent = false }
            
            self?.awaitingForContent = true
            
            let fetchedPosts: [any PostProtocol]?
            guard let dataSource = self?.dataSource else { return }
            switch dataSource {
            case .all:
                fetchedPosts = await self?.dataService?.getPosts(for: nil)
            case .favorite:
                guard let fetchedFavoritePosts = await self?.dataService?.getFavoritePosts() else {
                    self?.nothingToFetch = true
                    return
                }
                fetchedPosts = fetchedFavoritePosts
            }
            
            guard let fetchedPosts else { return }
            self?.posts.append(contentsOf: fetchedPosts)
            self?.postsUpdatesPublisher.send((indexes: nil, count: self?.posts.count, removedIndex: nil))
            
            self?.fetchMoreContentIfNeeded()
        }
    }
}
