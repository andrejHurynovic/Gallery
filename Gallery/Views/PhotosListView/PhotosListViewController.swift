//
//  PhotosListViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import UIKit
import Combine

final class PhotosListViewController: UIViewController {
    private let viewModel = PhotosListViewModel()
    private let helper = PhotosListHelper()
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let dummyView = UIView()
    private var previousSafeAreaWidth: CGFloat = -1
    private var safeAreaWidth: CGFloat { dummyView.bounds.width }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDummyView()
        previousSafeAreaWidth = safeAreaWidth
        configureCollectionView()
        addCollectionView()
        addCancellables()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewLayout()
    }
    
    private func update(itemsCount: Int) {
        helper.update(with: itemsCount)
        updateSnapshot()
    }
    
    // MARK: - Setup
    private func addCancellables() {
        viewModel.$photos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                self?.update(itemsCount: photos.count)
            }
            .store(in: &cancellables)
    }
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: helper.collectionViewLayout(for: requirements))
        dataSource = createDataSource(for: collectionView)
        collectionView.dataSource = dataSource
        collectionView.register(PhotoViewCell.self, forCellWithReuseIdentifier: PhotoViewCell.defaultReuseIdentifier)
    }
    
    // MARK: - Layout
    private func addCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    // Should be called before first createLayout call
    private func addDummyView() {
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dummyView)
        dummyView.isHidden = true
        NSLayoutConstraint.activate([
            dummyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            dummyView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            dummyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dummyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        dummyView.layoutIfNeeded()
    }
    
    // MARK: - Layout helper
    private func updateCollectionViewLayout() {
        guard previousSafeAreaWidth != safeAreaWidth else { return }
        previousSafeAreaWidth = safeAreaWidth
        let newLayout = helper.collectionViewLayout(for: requirements)
        
        updateSnapshot()
        collectionView.setCollectionViewLayout(newLayout, animated: true)
    }
}

private extension PhotosListViewController {
    var requirements: PhotosListHelper.CompositionalLayoutHelper.Requirements {
        PhotosListHelper.CompositionalLayoutHelper.Requirements(containerWidth: safeAreaWidth)
    }
}

// MARK: - DataSource
private extension PhotosListViewController {
    typealias SectionIdentifierType = Int
    typealias ItemIdentifierType = Int
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    
    func createDataSource(for collectionView: UICollectionView) -> DataSource {
        return DataSource(collectionView: collectionView, cellProvider: cellProvider)
    }
    
    func cellProvider(collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Int) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.defaultReuseIdentifier,
                                                            for: indexPath) as? PhotoViewCell else {
            return UICollectionViewCell()
        }
        
        viewModel.shouldRequestMoreContent(for: itemIdentifier)
        
        let photo = viewModel.photos[itemIdentifier]
        cell.update(with: photo)
        
        return cell
    }
    
    func updateSnapshot() {
        var snapshot = Snapshot()
        let indexesOfSections = helper.sectionIndexes
        
        snapshot.appendSections(indexesOfSections)
        for sectionsIndex in indexesOfSections {
            snapshot.appendItems(helper.itemIndexes(for: sectionsIndex), toSection: sectionsIndex)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
     
    func reloadItem(_ itemIdentifier: Int) {
        var snapshot = dataSource.snapshot() 
        snapshot.reloadItems([itemIdentifier])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Delegate
extension PhotosListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let itemIdentifier = helper.identifier(for: indexPath)
        let viewController = PhotoDetailViewController(viewModel: viewModel)
        
        present(viewController, animated: true)
        viewController.update(with: viewModel.photos[itemIdentifier], index: itemIdentifier)
        
        return true
    }
}

@available(iOS 17.0, *)
#Preview {
    PhotosListViewController()
}
