//
//  ImageBoxProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

protocol ImageBoxProtocol: AnyObject {
    associatedtype ImageType
    
    var width: Int { get }
    var height: Int { get }
    var image: ImageType { get }
    
    init?(from data: Data)
    
    func meet(requirements: any ImageRequirementsProtocol) -> Bool
}
