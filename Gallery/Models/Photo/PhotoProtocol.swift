//
//  PhotoProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

protocol PhotoProtocol: Identifiable {
    var id: String { get }
    
    var isPersistent: Bool { get set }
    
    var width: Int32 { get }
    var height: Int32 { get }
    var hexadecimalColorCode: String { get }
    
    var publicationDate: Date { get }
    var descriptionText: String? { get }
    var alternativeDescriptionText: String? { get }
    
    var views: Int32? { get }
    var likes: Int32 { get }
    var downloads: Int32? { get }
    
    var imageURL: String { get }
    var downloadURL: String { get }
    
    func updateWith(photo: any PhotoProtocol)
}
