//
//  CompositionalLayoutProvider.swift
//  UIKitLearning
//
//  Created by Andrej Hurynovič on 01.03.2025.
//

extension PostsListHelper {
    final class CompositionalLayoutProvider {
        private var storage: [CompositionalLayoutHelper.Requirements: CompositionalLayoutHelper] = [:]
        
        func helper(for requirements: CompositionalLayoutHelper.Requirements) -> CompositionalLayoutHelper {
            if let helper = storage[requirements] {
                return helper
            }
            let newHelper = CompositionalLayoutHelper(requirements: requirements)
            storage[requirements] = newHelper
            return newHelper
        }
    }
}
