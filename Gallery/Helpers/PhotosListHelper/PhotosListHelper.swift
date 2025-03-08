//
//  PhotosListHelper.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import UIKit

final class PhotosListHelper {
    private let layoutHelperProvider = CompositionalLayoutProvider()
    private var layoutHelper: CompositionalLayoutHelper!
    
    private var currentItemsCount: Int = 0
    private var itemsCountLimit = 0
    
    var sectionIndexes: [Int] = []
    private var sectionItemLimits: [Int] = []
    private var sectionOffsets: [Int] = [0]
    private var itemsInSections: [[Int]] = []
    
    // MARK: - Public
    func update(itemsCount: Int) {
        guard itemsCount != currentItemsCount else { return }
        if itemsCount > currentItemsCount {
            _ = itemsInSections.popLast()
        } else if itemsCount < currentItemsCount,
                  let lastSectionItemLimit = sectionItemLimits.popLast() {
            itemsCountLimit -= lastSectionItemLimit
            _ = sectionIndexes.popLast()
            if sectionOffsets.count > 1 {
                _ = sectionOffsets.popLast()
            }
            _ = itemsInSections.popLast()
        }
        while itemsCountLimit < itemsCount {
            let numberOfItemsInNewSection = layoutHelper.layoutSection(for: sectionItemLimits.count).numberOfItems
            itemsCountLimit += numberOfItemsInNewSection
            sectionItemLimits.append(numberOfItemsInNewSection)
            sectionIndexes.append(sectionIndexes.count)
        }
        currentItemsCount = itemsCount
    }
    
    func itemIndexes(for sectionIndex: Int) -> [Int] {
        if sectionIndex < itemsInSections.count {
            return itemsInSections[sectionIndex]
        }
        
        let fromIndex = sectionOffset(for: sectionIndex)
        let toIndex = min(currentItemsCount, fromIndex + sectionItemLimits[sectionIndex])
        let itemIndexes = Array(fromIndex..<toIndex)
        
        itemsInSections.append(itemIndexes)
        return itemIndexes
    }
    
    func collectionViewLayout(for requirements: CompositionalLayoutHelper.Requirements) -> UICollectionViewLayout {
        layoutHelper = layoutHelperProvider.helper(for: requirements)
        forceUpdate()
        
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            return self?.layoutSection(for: sectionIndex)
        }
    }
    
    func identifier(for indexPath: IndexPath) -> Int {
        sectionOffset(for: indexPath.section) + indexPath.item
    }
    
    // MARK: - Private
    private func forceUpdate() {
        let itemCount = currentItemsCount
        resetCache()
        update(itemsCount: itemCount)
    }
    
    private func layoutSection(for sectionIndex: Int) -> NSCollectionLayoutSection {
        layoutHelper.layoutSection(for: sectionIndex).section
    }
    
    private func sectionOffset(for sectionIndex: Int) -> Int {
        if sectionIndex < sectionOffsets.count {
            return sectionOffsets[sectionIndex]
        }
        
        let offset = (sectionOffsets.last ?? 0) + sectionItemLimits[sectionIndex - 1]
        sectionOffsets.append(offset)
        
        return offset
    }
    
    private func resetCache() {
        itemsCountLimit = 0
        currentItemsCount = 0
        sectionIndexes = []
        sectionItemLimits = []
        sectionOffsets = [0]
        itemsInSections = []
    }
}
