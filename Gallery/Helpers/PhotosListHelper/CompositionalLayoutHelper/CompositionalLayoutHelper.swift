//
//  CompositionalLayoutHelper.swift
//  UIKitLearning
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import UIKit

extension PhotosListHelper {
    final class CompositionalLayoutHelper {
        private let requirements: Requirements
        private var cache: [(section: NSCollectionLayoutSection, numberOfItems: Int)] = []
        
        // MARK: - Initializer
        init(requirements: Requirements) {
            self.requirements = requirements
        }
        
        // MARK: - Layout Items
        private lazy var smallSquareSize = requirements.collectionLayoutDimension(heightMultiplier: 1, widthMultiplier: 1)
        private lazy var bigSquareSize = requirements.collectionLayoutDimension(heightMultiplier: 2, widthMultiplier: 2)
        private lazy var verticalRectangleSize = requirements.collectionLayoutDimension(heightMultiplier: 2, widthMultiplier: 1)
        private lazy var horizontalRectangleSize = requirements.collectionLayoutDimension(heightMultiplier: 1, widthMultiplier: 2)
        
        private lazy var smallSquare = NSCollectionLayoutItem(layoutSize: smallSquareSize)
        private lazy var bigSquare = NSCollectionLayoutItem(layoutSize: bigSquareSize)
        private lazy var verticalRectangle = NSCollectionLayoutItem(layoutSize: verticalRectangleSize)
        private lazy var horizontalRectangle = NSCollectionLayoutItem(layoutSize: horizontalRectangleSize)
        
        // MARK: - Public
        func layoutSection(for sectionIndex: Int) -> (section: NSCollectionLayoutSection, numberOfItems: Int) {
            if sectionIndex >= cache.count {
                let layoutSection = createLayoutSection()
                cache.append(layoutSection)
                return layoutSection
            } else {
                return cache[sectionIndex]
            }
        }
        
        // MARK: - Private
        private func createLayoutSection() -> (section: NSCollectionLayoutSection, numberOfItems: Int) {
            var columnsLeft = requirements.numberOfColumns
            var verticalGroups: [CollectionLayoutGroupBox] = []
            
            while columnsLeft > 0 {
                if columnsLeft == 1 {
                    verticalGroups.append(generateRandomVerticalGroup())
                    columnsLeft -= 1
                } else {
                    if Bool.random() {
                        verticalGroups.append(generateRandomDoubleSizedVerticalGroup())
                        columnsLeft -= 2
                    } else {
                        verticalGroups.append(generateRandomVerticalGroup())
                        columnsLeft -= 1
                    }
                }
            }
            let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute((requirements.itemHeight * 3) + (requirements.itemSpacing * 2)))
            let group = combineGroups(verticalGroups, axis: .horizontal, layoutSize: layoutSize)
            guard let groupItem = group.item as? NSCollectionLayoutGroup else {
                fatalError("combineGroups method returned impossible item")
            }
            let section = NSCollectionLayoutSection(group: groupItem)
            section.contentInsets = .init(top: requirements.itemSpacing, leading: requirements.itemSpacing, bottom: 0, trailing: 0)
            
            return (section, group.itemsCount)
        }
    }
}
// MARK: - Random Group Generators
extension PhotosListHelper.CompositionalLayoutHelper {
    private func generateRandomVerticalGroup() -> CollectionLayoutGroupBox {
        let subitems: [NSCollectionLayoutItem]
        switch Int.random(in: 0...2) {
        case 0: subitems = Array(repeating: smallSquare, count: 3)
        case 1: subitems = [smallSquare, verticalRectangle]
        default: subitems = [verticalRectangle, smallSquare]
        }
        
        return CollectionLayoutGroupBox(item: createVerticalGroup(from: subitems, heightMultiplier: 3, widthMultiplier: 1), itemsCount: subitems.count)
    }
    
    private func generateRandomHorizontalRectangle() -> CollectionLayoutGroupBox {
        let subitems: [NSCollectionLayoutItem] = Bool.random() ? [horizontalRectangle] : [smallSquare, smallSquare]
        return CollectionLayoutGroupBox(item: createHorizontalGroup(from: subitems, heightMultiplier: 1, widthMultiplier: 2), itemsCount: subitems.count)
    }
    
    private func generateRandomVerticalRectangle() -> CollectionLayoutGroupBox {
        let subitems: [NSCollectionLayoutItem] = Bool.random() ? [verticalRectangle] : [smallSquare, smallSquare]
        return CollectionLayoutGroupBox(item: createVerticalGroup(from: subitems, heightMultiplier: 2, widthMultiplier: 1), itemsCount: subitems.count)
    }
    
    private func generateRandomBigSquare() -> CollectionLayoutGroupBox {
        return switch Int.random(in: 0...3) {
        case 0:
            CollectionLayoutGroupBox(item: bigSquare, itemsCount: 1)
        case 1:
            combineGroups([generateRandomHorizontalRectangle(), generateRandomHorizontalRectangle()], axis: .vertical, layoutSize: bigSquareSize)
        default:
            combineGroups([generateRandomVerticalRectangle(), generateRandomVerticalRectangle()], axis: .horizontal, layoutSize: bigSquareSize)
        }
    }
    
    private func generateRandomDoubleSizedVerticalGroup() -> CollectionLayoutGroupBox {
        let groups = Bool.random() ? [generateRandomHorizontalRectangle(), generateRandomBigSquare()] : [generateRandomBigSquare(), generateRandomHorizontalRectangle()]
        return combineGroups(groups, axis: .vertical, layoutSize: requirements.collectionLayoutDimension(heightMultiplier: 3, widthMultiplier: 2))
    }
}

// MARK: - Group Combination Helper
extension PhotosListHelper.CompositionalLayoutHelper {
    private func combineGroups(_ boxes: [CollectionLayoutGroupBox], axis: CollectionLayoutGroupBoxJoinedAxis, layoutSize: NSCollectionLayoutSize) -> CollectionLayoutGroupBox {
        let subitems = boxes.map { $0.item }
        let itemCount = boxes.reduce(0) { $0 + $1.itemsCount }
        
        let group: NSCollectionLayoutGroup
        switch axis {
        case .vertical:
            group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, subitems: subitems)
        case .horizontal:
            group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: subitems)
        }
        group.interItemSpacing = .fixed(requirements.itemSpacing)
        
        return CollectionLayoutGroupBox(item: group, itemsCount: itemCount)
    }
}

// MARK: - Helpers
extension PhotosListHelper.CompositionalLayoutHelper {
    private func createVerticalGroup(from items: [NSCollectionLayoutItem], heightMultiplier: CGFloat, widthMultiplier: CGFloat) -> NSCollectionLayoutGroup {
        let group = NSCollectionLayoutGroup.vertical(layoutSize: requirements.collectionLayoutDimension(heightMultiplier: heightMultiplier, widthMultiplier: widthMultiplier), subitems: items)
        group.interItemSpacing = .fixed(requirements.itemSpacing)
        return group
    }
    
    private func createHorizontalGroup(from items: [NSCollectionLayoutItem], heightMultiplier: CGFloat, widthMultiplier: CGFloat) -> NSCollectionLayoutGroup {
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: requirements.collectionLayoutDimension(heightMultiplier: heightMultiplier, widthMultiplier: widthMultiplier), subitems: items)
        group.interItemSpacing = .fixed(requirements.itemSpacing)
        return group
    }
}
