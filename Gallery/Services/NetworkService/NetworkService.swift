//
//  NetworkService.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Foundation
import Network

final class NetworkService: NetworkServiceProtocol {
    @Injected var alertService: (any AlertServiceProtocol)?

    private let session = {
        let configuration = URLSessionConfiguration.default
        // Ignoring cache to properly check persistence
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    func fetch(_ endpoint: APIEndpointProtocol) async -> Data? {
        guard let request = endpoint.request else { return nil }
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return nil
            }
            
            return await handleResponse(data: data, response: httpResponse)
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled { return nil }

            await alertService?.showAlert(for: error)
            return nil
        }
    }
    
    private func handleResponse(data: Data, response: HTTPURLResponse) async -> Data? {
        switch response.statusCode {
        case 200..<300:
            return data
        case 401:
            await alertService?.showAlert(for: NetworkServiceError.incorrectAPIKey)
        case 403:
            await alertService?.showAlert(for: NetworkServiceError.rateLimitExceeded)
        default:
            await alertService?.showAlert(for: URLError(.init(rawValue: response.statusCode)))
        }
        return nil
    }
}
