//
//  PhotosListViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import UIKit
import Combine

final class PhotosListViewController: UIViewController {
    private let viewModel: PhotosListViewModel
    private let helper = PhotosListHelper()
    
    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var previousItemsCount: Int = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let dummyView = UIView()
    private var previousSafeAreaWidth: CGFloat = -1
    private var safeAreaWidth: CGFloat { dummyView.bounds.width }
    
    // MARK: - Initialization
    init(viewModel: PhotosListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDummyView()
        previousSafeAreaWidth = safeAreaWidth
        configureCollectionView()
        addCollectionView()
        addCancellables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startMonitor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewLayout()
    }
    
    private func update(itemsCount: Int) {
        helper.update(itemsCount: itemsCount)
        if previousItemsCount > itemsCount {
            updateSnapshot(force: true)
            collectionView.reloadData()
        } else {
            updateSnapshot(force: false)
        }
        previousItemsCount = itemsCount
    }
    
    // MARK: - Setup
    private func addCancellables() {
        viewModel.photosUpdatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (indexes, count) in
                if let count = count {
                    self?.update(itemsCount: count)
                }
                if let indexes {
                    self?.reloadItems(indexes)
                }
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
        
        updateSnapshot(force: true)
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
                                                            for: indexPath) as? PhotoViewCell,
              let photo = viewModel.photo(for: itemIdentifier) else {
            return UICollectionViewCell()
        }
        
        viewModel.fetchMoreContentIfNeeded(for: itemIdentifier)
        
        cell.update(with: photo)
        
        return cell
    }
    
    func updateSnapshot(force: Bool = false) {
        let indexesOfSections: [Int]
        var snapshot: Snapshot
        
        if force {
            snapshot = Snapshot()
            indexesOfSections = helper.sectionIndexes
        } else {
            snapshot = dataSource.snapshot()
            if let lastSectionIndex = snapshot.sectionIdentifiers.last {
                let newItemsForLastSection = helper.itemIndexes(for: lastSectionIndex).filter {
                    !snapshot.itemIdentifiers(inSection: lastSectionIndex).contains($0)
                }
                snapshot.appendItems(newItemsForLastSection, toSection: lastSectionIndex)
            }
            indexesOfSections = helper.sectionIndexes.filter { !snapshot.sectionIdentifiers.contains($0) }
        }
        
        snapshot.appendSections(indexesOfSections)
        for sectionsIndex in indexesOfSections {
            snapshot.appendItems(helper.itemIndexes(for: sectionsIndex), toSection: sectionsIndex)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadItems(_ itemIdentifiers: [Int]) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Delegate
extension PhotosListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let itemIdentifier = helper.identifier(for: indexPath)
        let viewController = PhotoDetailViewController(viewModel: viewModel)
        
        present(viewController, animated: true)
        viewController.update(index: itemIdentifier)
        
        return true
    }
}

@available(iOS 17.0, *)
#Preview {
    PhotosListViewController(viewModel: PhotosListViewModel(dataSource: .all))
}
