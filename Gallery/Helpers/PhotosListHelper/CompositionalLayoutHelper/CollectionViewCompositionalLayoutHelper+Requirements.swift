//
//  CompositionalLayoutHelper+Requirements.swift
//  UIKitLearning
//
//  Created by Andrej Hurynovič on 01.03.2025.
//

import UIKit

extension PhotosListHelper.CompositionalLayoutHelper {
    struct Requirements: Hashable {
        let numberOfColumns: Int
        let itemHeight: CGFloat
        let itemWidth: CGFloat
        let itemSpacing: CGFloat
        
        func collectionLayoutDimension(heightMultiplier: CGFloat, widthMultiplier: CGFloat) -> NSCollectionLayoutSize {
            let width = (itemWidth * widthMultiplier) + (itemSpacing * (widthMultiplier - 1))
            let height = (itemHeight * heightMultiplier) + (itemSpacing * (heightMultiplier - 1))
            return NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height))
        }
        
        init(containerWidth: CGFloat,
             minimalItemWidth: CGFloat = Constants.UserInterface.photoCellMinimalWidth,
             itemHeight: CGFloat = Constants.UserInterface.photoCellHeight,
             itemSpacing: CGFloat = Constants.UserInterface.horizontalSpacing) {
            self.numberOfColumns = Int((containerWidth / (minimalItemWidth + itemSpacing)).rounded(.down))
            let totalSpacing = CGFloat(numberOfColumns + 1) * itemSpacing
            self.itemWidth = (containerWidth - totalSpacing) / CGFloat(numberOfColumns)
            self.itemHeight = itemHeight
            self.itemSpacing = itemSpacing
        }
    }
}
