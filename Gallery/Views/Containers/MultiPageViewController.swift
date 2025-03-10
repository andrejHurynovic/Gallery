//
//  MultiPageViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 06.03.2025.
//

import UIKit

final class MultiPageViewController: UIPageViewController {
    private let currentTitleButton = UILabel(font: .preferredFont(forTextStyle: .largeTitle))
    private let nextTitleButton = UILabel(font: .preferredFont(forTextStyle: .largeTitle))
    private let upcomingLabel = UILabel(font: .preferredFont(forTextStyle: .largeTitle))
    
    lazy var scrollView: UIScrollView? = { return view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView }()
    
    private let pages: [UIViewController]
    private var previousPageIndex: Int = 0
    
    // MARK: - Initialization
    init(pages: [UIViewController]) {
        self.pages = pages
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        guard let firstViewController = pages.first else { return }
        setViewControllers([firstViewController], direction: .forward, animated: true)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        view.backgroundColor = .systemBackground
        
        scrollView?.delegate = self
        setupNavigationBar()
        setupLabels()
        updateTitleLabels(for: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTitles()
    }
    
    // MARK: - Setup
    private func setupLabels() {
        [currentTitleButton, nextTitleButton, upcomingLabel].forEach {
            $0.font = UIFont.preferredFont(forTextStyle: .largeTitle).withTraits(traits: .traitBold)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: currentTitleButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextTitleButton)
        nextTitleButton.addSubview(upcomingLabel)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    // MARK: - Private
    private func updateTitleLabels(for index: Int) {
        currentTitleButton.text = pages[index].title
        
        nextTitleButton.text = index + 1 < pages.count ? pages[index + 1].title : nil
        upcomingLabel.text = index + 2 < pages.count ? pages[index + 2].title : nil
    }
    
    private func updateTitles() {
        let tuple: (index: Int, viewController: UIViewController) = pages.enumerated().first { (_, controller) in
            controller.view.convert(controller.view.frame, to: view).origin.x < 0
        } ?? (0, pages.first!)
        
        let offsetRatio = -(tuple.viewController.view.convert(tuple.viewController.view.frame, to: view).origin.x / view.bounds.width)
        let currentViewController = Int(abs(offsetRatio)) + tuple.index
        
        if currentViewController != previousPageIndex {
            previousPageIndex = currentViewController
            updateTitleLabels(for: currentViewController)
        }
        
        applyTransformations(for: offsetRatio.truncatingRemainder(dividingBy: 1.0))
    }
    
    private func applyTransformations(for ratio: CGFloat) {
        // currentButton
        let currentScale = 1.0 + (0.5 * ratio)
        let currentTranslation = -(view.bounds.width * ratio * 2)
        currentTitleButton.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
            .translatedBy(x: currentTranslation, y: 0)
        
        // nextButton
        nextTitleButton.transform = .identity
        
        guard let currentTitleSuperview = currentTitleButton.superview,
              let nextTitleSuperview = nextTitleButton.superview else { return }
        
        let minimalNextScale = 0.7
        let nextScale = minimalNextScale + (0.3 * ratio)
        
        let maximalNextTranslation = currentTitleSuperview.frame.minX - nextTitleSuperview.frame.minX
        let nextTranslation = maximalNextTranslation * ratio
        
        let minimalNextAlpha = 0.5
        let nextAlpha = (1 - 0.5) + (0.5 * ratio)
        
        let originalNextWidth = nextTitleButton.frame.width
        let scaledNextWidth = originalNextWidth * nextScale
        let nextWidthDifference = scaledNextWidth - originalNextWidth
        
        let adjustedTranslation = nextTranslation - (nextWidthDifference / 2)
        
        nextTitleButton.transform = CGAffineTransform(translationX: adjustedTranslation, y: 0)
            .scaledBy(x: nextScale, y: nextScale)
        nextTitleButton.alpha = nextAlpha
        
        // upcomingLabel
        upcomingLabel.transform = .identity
        
        let originalUpcomingWidth = upcomingLabel.frame.width
        let scaledUpcomingWidth = originalUpcomingWidth * minimalNextScale
        let upcomingWidthDifference = scaledUpcomingWidth - originalUpcomingWidth
        
        let upcomingTranslation = -(maximalNextTranslation - (nextTitleButton.bounds.width - upcomingLabel.bounds.width)) - (upcomingWidthDifference / 2)
        
        upcomingLabel.transform = CGAffineTransform(translationX: upcomingTranslation, y: 0)
            .scaledBy(x: minimalNextScale, y: minimalNextScale)
        upcomingLabel.alpha = minimalNextAlpha
    }
}

// MARK: - UIScrollViewDelegate
extension MultiPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateTitles()
    }
}

// MARK: - DataSource
extension MultiPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController),
              index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController),
              (index + 1) < pages.count else { return nil }
        return pages[index + 1]
    }
}

@available(iOS 17.0, *)
#Preview {
    let viewControllers = Array(0...4).map {
        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
        viewController.title = "Page \($0)"
        return viewController
    }
    
    let navigationController = UINavigationController(rootViewController: MultiPageViewController(pages: viewControllers))
    navigationController
}
