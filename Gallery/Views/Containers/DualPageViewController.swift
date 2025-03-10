//
//  DualPageViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 06.03.2025.
//

import UIKit

final class DualPageViewController: UIPageViewController {
    private let leadingLabel = UILabel(font: .preferredFont(forTextStyle: .largeTitle))
    private let trailingLabel = UILabel(font: .preferredFont(forTextStyle: .largeTitle))
    
    lazy var scrollView: UIScrollView? = {
        return view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }()
    
    private var transitionTarget: UIViewController?
    private var currentViewController: UIViewController
    private let leadingViewController: UIViewController
    private let trailingViewController: UIViewController
    
    // MARK: - Initialization
    init(leadingViewController: UIViewController, trailingViewController: UIViewController, leadingText: String, trailingText: String) {
        self.leadingViewController = leadingViewController
        self.trailingViewController = trailingViewController
        self.currentViewController = leadingViewController
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        leadingLabel.text = leadingText
        trailingLabel.text = trailingText
        setupLabels()
        setViewControllers([leadingViewController], direction: .forward, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupNavigationBar()
        updateConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        view.backgroundColor = .systemBackground
        
        scrollView?.delegate = self
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupLabels() {
        [leadingLabel, trailingLabel].forEach {
            $0.font = UIFont.preferredFont(forTextStyle: .largeTitle).withTraits(traits: .traitBold)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leadingLabel)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: trailingLabel)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    // MARK: - Private
    private func updateConstraints() {
        guard let scrollView = scrollView else { return }
        
        let realOffset = scrollView.contentOffset.x
        let maxOffset = view.bounds.width
        let offset = realOffset.truncatingRemainder(dividingBy: maxOffset)
        
        if realOffset == view.bounds.width {
            transitionTarget = nil
        }
        
        var offsetRatio = offset / maxOffset
        if transitionTarget == nil && currentViewController == leadingViewController {
            offsetRatio = 0.0
        } else if transitionTarget == nil && currentViewController == trailingViewController {
            return
        } else if transitionTarget == nil {
            return
        }
        
        if realOffset < maxOffset && transitionTarget != leadingViewController {
            return
        }
        if realOffset > maxOffset && transitionTarget != trailingViewController {
            return
        }
        if transitionTarget == trailingViewController, offset == 0 {
            return
        }
        
        let leadingTransformScale = 1.0 + (0.5 * offsetRatio)
        leadingLabel.transform = CGAffineTransform(scaleX: leadingTransformScale, y: leadingTransformScale)
            .translatedBy(x: -offset * 2, y: 0)
        
        guard let leadingLabelSuperviewLeading = leadingLabel.superview?.frame.minX,
              let trailingLabelSuperviewLeading = trailingLabel.superview?.frame.minX else { return }
        
        let fullTrailingLabelTransition = leadingLabelSuperviewLeading - trailingLabelSuperviewLeading
        let trailingTransformScale = 0.7 + (0.3 * offsetRatio)
        let trailingAlpha = 0.5 + (0.5 * offsetRatio)
        trailingLabel.alpha = trailingAlpha
        trailingLabel.transform = CGAffineTransform(scaleX: trailingTransformScale, y: trailingTransformScale)
            .translatedBy(x: fullTrailingLabelTransition * offsetRatio, y: 0)
    }
}

// MARK: - UIScrollViewDelegate
extension DualPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateConstraints()
    }
}

// MARK: - UIPageViewControllerDelegate
extension DualPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        currentViewController = self.viewControllers!.first!
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        transitionTarget = pendingViewControllers.first
    }
}

// MARK: - DataSource
extension DualPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard viewController == trailingViewController else { return nil }
        return leadingViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard viewController == leadingViewController else { return nil }
        return trailingViewController
    }
}

@available(iOS 17.0, *)
#Preview {
    let leadingViewController = {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBlue
        return viewController
    }()
    let trailingViewController = {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemGreen
        return viewController
    }()
    let navigationController = UINavigationController(rootViewController: DualPageViewController(leadingViewController: leadingViewController,
                                                                                                 trailingViewController: trailingViewController,
                                                                                                 leadingText: "leading",
                                                                                                 trailingText: "trailing"))
    return navigationController
}
