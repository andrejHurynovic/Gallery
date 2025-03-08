//
//  ReusablePageViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 07.03.2025.
//

import UIKit

class ReusablePagesViewController<T: ReusablePageViewController>: UIPageViewController,
                                                                  UIPageViewControllerDataSource,
                                                                  UIPageViewControllerDelegate {
    private var reusableViewControllers = Set<T>(minimumCapacity: 3)
    private var currentViewController: T?
    open var dataCount: Int { 0 }
    
    // MARK: - Initialization
    init(initialIndex: Int) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        delegate = self
        dataSource = self
        
        let viewController = dequeueReusableViewController()
        viewController.update(index: initialIndex)
        currentViewController = viewController
        setViewControllers([viewController], direction: .forward, animated: true)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Public
    open func remove(index removedIndex: Int) {
        guard dataCount > 0 else {
            dismiss(animated: true)
            return
        }
        performTransition(removedIndex)
    }
    
    open func createReusableViewController() -> T {
        T()
    }
    
    // MARK: - Private
    fileprivate func performTransition(_ removedIndex: Int) {
        let sortedViewControllers = reusableViewControllers.sorted { $0.index > $1.index }
        
        var nextViewController: T?
        var previousViewController: T?
        var removedIndexViewController: T?
        
        let shouldTransit = currentViewController?.index == removedIndex
        
        for reusableViewController in sortedViewControllers {
            guard let index = reusableViewController.index else { break }
            switch index {
            case (removedIndex + 1)...:
                reusableViewController.index -= 1
                nextViewController = reusableViewController
            case removedIndex:
                removedIndexViewController = reusableViewController
                reusableViewController.index -= 1
            case ...(removedIndex - 1):
                previousViewController = reusableViewController
            default: break
            }
        }
        
        if !shouldTransit {
            guard let removedIndexViewController else { return }
            removedIndexViewController.update(index: removedIndexViewController.index)
        } else if let nextViewController = nextViewController ?? reusableViewController(after: removedIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true)
        } else if let previousViewController = previousViewController ?? reusableViewController(before: removedIndex) {
            setViewControllers([previousViewController], direction: .reverse, animated: true)
        }
    }
    
    // MARK: - Reusable view controllers
    private func dequeueReusableViewController() -> T {
        if let reusableViewController = reusableViewControllers.first(where: { $0.parent != self }) {
            return reusableViewController
        } else {
            let viewController = createReusableViewController()
            reusableViewControllers.insert(viewController)
            return viewController
        }
    }
    
    private func reusableViewController(after index: Int) -> T? {
        let nextIndex = index + 1
        guard dataCount > nextIndex else { return nil }
        let nextViewController = dequeueReusableViewController()
        nextViewController.update(index: nextIndex)
        return nextViewController
    }
    
    private func reusableViewController(before index: Int) -> T? {
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        let previousViewController = dequeueReusableViewController()
        previousViewController.update(index: previousIndex)
        return previousViewController
    }
    
    // MARK: - DataSource
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? T)?.index else { return nil }
        return reusableViewController(after: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? T)?.index else { return nil }
        return reusableViewController(before: index)
    }
    
    // MARK: Delegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        currentViewController = viewControllers?.first as? T
    }
}

@available(iOS 17.0, *)
#Preview { ReusablePagesViewController(initialIndex: 3) }

final class PhotoDetailPagesViewController: ReusablePagesViewController<PhotoDetailViewController> {
    var viewModel: PhotosListViewModel
    override var dataCount: Int { viewModel.photosCount }
    
    init(initialIndex: Int, viewModel: PhotosListViewModel) {
        self.viewModel = viewModel
        super.init(initialIndex: initialIndex)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func createReusableViewController() -> PhotoDetailViewController {
        PhotoDetailViewController(viewModel: viewModel)
    }
}
