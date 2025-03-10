//
//  MultiPageViewController.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 06.03.2025.
//

import UIKit

class MultiPageViewController: UIPageViewController {
    private let currentTitle = UILabel(font: .preferredFont(forTextStyle: .largeTitle))
    private let nextTitle = UILabel(font: .preferredFont(forTextStyle: .largeTitle))
    private let upcomingTitle = UILabel(font: .preferredFont(forTextStyle: .largeTitle))
    
    lazy private var scrollView: UIScrollView? = { return view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView }()
    
    private let pages: [UIViewController]
    private var currentIndex: Int? { pages.firstIndex(where: { $0 == self.viewControllers?.first }) }
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
        setupLabels()
        setupNavigationBar()
        updateTitleLabels(for: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTitles()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: currentTitle)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextTitle)
        nextTitle.addSubview(upcomingTitle)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    private func setupLabels() {
        let font = UIFont.preferredFont(forTextStyle: .largeTitle).withTraits(traits: .traitBold)
        [currentTitle, nextTitle, upcomingTitle].forEach {
            $0.font = font
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Adding tap gesture recognizers
        let currentTitleTapGesture = UITapGestureRecognizer(target: self, action: #selector(currentTitleTapped))
        currentTitle.isUserInteractionEnabled = true
        currentTitle.addGestureRecognizer(currentTitleTapGesture)
        
        let nextTitleTapGesture = UITapGestureRecognizer(target: self, action: #selector(nextTitleTapped))
        nextTitle.isUserInteractionEnabled = true
        nextTitle.addGestureRecognizer(nextTitleTapGesture)
    }
    
    // MARK: - Public
    open func getTitles(for index: Int) -> (currentTitle: String?, nextTitle: String?, upcomingTitle: String?) {
        (currentTitle: pages[index].title,
         nextTitle: index + 1 < pages.count ? pages[index + 1].title : nil,
         upcomingTitle: index + 2 < pages.count ? pages[index + 2].title : nil)
    }
    
    open func setPreviousPage(for index: Int?) {
        guard let index, index > 0 else { return }
        setViewControllers([pages[index - 1]], direction: .reverse, animated: true) { _ in
            self.updateTitles()
        }
    }
    open func setNextPage(for index: Int?) {
        guard let index, index + 1 < pages.count  else { return }
        setViewControllers([pages[index + 1]], direction: .forward, animated: true) { _ in
            self.updateTitles()
        }
    }
    
    // MARK: - Private
    private func updateTitleLabels(for index: Int) {
        let titles = getTitles(for: index)
        currentTitle.text = titles.currentTitle
        nextTitle.text = titles.nextTitle
        upcomingTitle.text = titles.upcomingTitle
    }
    
    private func updateTitles() {
        let tuple: (index: Int, viewController: UIViewController) = pages.enumerated().first { (_, controller) in
            return controller.view.convert(controller.view.frame, to: view).origin.x < 0
        } ?? (previousPageIndex, viewControllers!.first!)
        
        let offsetRatio = -(tuple.viewController.view.convert(tuple.viewController.view.frame, to: view).origin.x / view.bounds.width)
        let currentPageIndex = Int(abs(offsetRatio)) + tuple.index
        
        if currentPageIndex != previousPageIndex {
            previousPageIndex = currentPageIndex
            updateTitleLabels(for: currentPageIndex)
        }
        
        applyTransformations(for: offsetRatio.truncatingRemainder(dividingBy: 1.0))
    }
    
    private func applyTransformations(for ratio: CGFloat) {
        // currentButton
        let currentScale = 1.0 + (0.5 * ratio)
        let currentTranslation = -(view.bounds.width * ratio * 2)
        currentTitle.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
            .translatedBy(x: currentTranslation, y: 0)
        
        // nextButton
        nextTitle.transform = .identity
        
        guard let currentTitleSuperview = currentTitle.superview,
              let nextTitleSuperview = nextTitle.superview else { return }
        
        let minimalNextScale = 0.7
        let nextScale = minimalNextScale + (0.3 * ratio)
        
        let maximalNextTranslation = currentTitleSuperview.frame.minX - nextTitleSuperview.frame.minX
        let nextTranslation = maximalNextTranslation * ratio
        
        let minimalNextAlpha = 0.5
        let nextAlpha = (1 - 0.5) + (0.5 * ratio)
        
        let originalNextWidth = nextTitle.frame.width
        let scaledNextWidth = originalNextWidth * nextScale
        let nextWidthDifference = scaledNextWidth - originalNextWidth
        
        let adjustedTranslation = nextTranslation - (nextWidthDifference / 2)
        
        nextTitle.transform = CGAffineTransform(translationX: adjustedTranslation, y: 0)
            .scaledBy(x: nextScale, y: nextScale)
        nextTitle.alpha = nextAlpha
        
        // upcomingLabel
        upcomingTitle.transform = .identity
        
        let originalUpcomingWidth = upcomingTitle.frame.width
        let scaledUpcomingWidth = originalUpcomingWidth * minimalNextScale
        let upcomingWidthDifference = scaledUpcomingWidth - originalUpcomingWidth
        
        let upcomingTranslation = -(maximalNextTranslation - (nextTitle.bounds.width - upcomingTitle.bounds.width)) - (upcomingWidthDifference / 2)
        
        upcomingTitle.transform = CGAffineTransform(translationX: upcomingTranslation, y: 0)
            .scaledBy(x: minimalNextScale, y: minimalNextScale)
        upcomingTitle.alpha = minimalNextAlpha
    }
    
    // MARK: - Actions
    @objc private func currentTitleTapped() {
        setPreviousPage(for: currentIndex)
    }
    
    @objc private func nextTitleTapped() {
        setNextPage(for: currentIndex)
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
        viewController.view.backgroundColor = UIColor(red: CGFloat.random(in: 0...1),
                                                      green: CGFloat.random(in: 0...1),
                                                      blue: CGFloat.random(in: 0...1),
                                                      alpha: 1.0)
        viewController.title = "Page \($0)"
        return viewController
    }
    
    let navigationController = UINavigationController(rootViewController: MultiPageViewController(pages: viewControllers))
    navigationController
}
