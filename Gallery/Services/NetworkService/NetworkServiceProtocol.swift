//
//  NetworkServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    var networkAvailablyPublisher: AnyPublisher<Bool, Never> { get }
    
    func fetch(_ endpoint: APIEndpointProtocol) async -> Data?
}
