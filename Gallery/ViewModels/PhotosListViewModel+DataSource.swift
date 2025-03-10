//
//  PhotosListViewModel+DataSource.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 07.03.2025.
//

extension PhotosListViewModel {
    enum DataSource {
        case all
        case favorite
        
        var title: String {
            switch self {
            case .all: return "All"
            case .favorite: return "Favorite"
            }
        }
    }
}
