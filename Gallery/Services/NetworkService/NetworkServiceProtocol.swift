//
//  NetworkServiceProtocol.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetch(_ endpoint: APIEndpointProtocol) async -> Data?
}
