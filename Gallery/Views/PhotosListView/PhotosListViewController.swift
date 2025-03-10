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
    
    private var visibleSections: [Int] { Array(Set(collectionView.indexPathsForVisibleItems.map({ $0.section }))) }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let dummyView = UIView()
    private var previousSafeAreaWidth: CGFloat = -1
    private var safeAreaWidth: CGFloat { dummyView.bounds.width }
    
    private var isBackButtonVisible = true
    private var backButtonTrailingConstraint: NSLayoutConstraint!
    private lazy var backButton = {
        let button = ImageButton(image: UIImage(resource: .chevronUp), action: { [weak self] in self?.scrollToTop() })
        let buttonContainer = RoundedContainerView(content: button, cornerStyle: .circle)
        return buttonContainer
    }()
    
    private weak var photoDetailPagesViewController: PhotoDetailPagesViewController?
    
    // MARK: - Initialization
    init(viewModel: PhotosListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.dataSource.title
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDummyView()
        previousSafeAreaWidth = safeAreaWidth
        configureCollectionView()
        addCollectionView()
        addBackButton()
        addCancellables()
        viewModel.startMonitor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewLayout()
    }
    
    private func update(itemsCount: Int) {
        helper.update(itemsCount: itemsCount)
        if previousItemsCount > itemsCount {
            helper.update(itemsCount: itemsCount)
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
            .sink { [weak self] (indexes, count, removedIndex) in
                if let removedIndex {
                    self?.photoDetailPagesViewController?.remove(index: removedIndex)
                }
                if let count, indexes != nil {
                    self?.update(itemsCount: count)
                    self?.reloadSections(self!.visibleSections)
                    return
                }
                if let count {
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
        collectionView.showsVerticalScrollIndicator = false
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    private func addBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        backButtonTrailingConstraint = backButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        updateBackButtonTrailingConstraint()
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -Constants.UserInterface.horizontalSpacing / 2),
            backButtonTrailingConstraint,
            backButton.widthAnchor.constraint(equalToConstant: Constants.UserInterface.mediumButtonSize),
            backButton.heightAnchor.constraint(equalToConstant: Constants.UserInterface.mediumButtonSize)
        ])
    }
    
    private func updateBackButtonTrailingConstraint() {
        let isBackButtonVisible: Bool
        if self.collectionView.contentOffset.y > self.view.bounds.height / 4 {
            isBackButtonVisible = true
        } else {
            isBackButtonVisible = false
        }
        if self.isBackButtonVisible != isBackButtonVisible {
            self.isBackButtonVisible = isBackButtonVisible
            if isBackButtonVisible {
                backButtonTrailingConstraint.constant = -Constants.UserInterface.horizontalSpacing / 2
            } else {
                backButtonTrailingConstraint.constant = 100
            }
            UIView.animate(withDuration: Constants.animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    private func scrollToTop() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
    
    private var cellProvider: (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ itemIdentifier: ItemIdentifierType) -> UICollectionViewCell? {
        { [weak self] collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.defaultReuseIdentifier,
                                                                for: indexPath) as? PhotoViewCell,
                  let photo = self?.viewModel.photo(for: itemIdentifier) else {
                return UICollectionViewCell()
            }
            
            cell.viewModel = self?.viewModel
            cell.update(with: photo, index: itemIdentifier)
            
            return cell
        }
    }
    
    func cellProvider(collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Int) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewCell.defaultReuseIdentifier,
                                                            for: indexPath) as? PhotoViewCell,
              let photo = viewModel.photo(for: itemIdentifier) else {
            return UICollectionViewCell()
        }
        
        cell.viewModel = viewModel
        cell.update(with: photo, index: itemIdentifier)
        
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
    
    func reloadItems(_ itemsIdentifiers: [Int]) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(itemsIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    func reloadSections(_ sectionsIdentifiers: [Int]) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections(sectionsIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Delegate
extension PhotosListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let itemIdentifier = helper.identifier(for: indexPath)
        let viewController = PhotoDetailPagesViewController(initialIndex: itemIdentifier, viewModel: viewModel)
        
        photoDetailPagesViewController = viewController
        present(UINavigationController(rootViewController: viewController), animated: true)
        return true
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateBackButtonTrailingConstraint()
    }
}

@available(iOS 17.0, *)
#Preview {
    PhotosListViewController(viewModel: PhotosListViewModel(dataSource: .all))
}
