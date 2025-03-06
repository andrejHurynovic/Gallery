//
//  PhotoProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

protocol PhotoProtocol: Identifiable {
    var id: String { get }
    
    var isFavorite: Bool { get set }
    
    var width: Int { get }
    var height: Int { get }
    var hexadecimalColorCode: String { get }
    
    var publishedDate: Date { get }
    var descriptionText: String? { get }
    var alternativeDescriptionText: String? { get }
    
    var views: Int? { get }
    var likes: Int { get }
    var downloads: Int? { get }
    
    var location: Location? { get }
    
    var imageURL: String { get }
    var downloadURL: String { get }
}
