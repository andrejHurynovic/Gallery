//
//  ImageRequirementsProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

protocol ImageRequirementsProtocol {
    var id: String { get }
    var imageURL: String { get }
    
    var requiredWidth: Int { get }
    var requiredHeight: Int { get }
}
