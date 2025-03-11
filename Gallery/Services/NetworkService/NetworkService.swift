//
//  NetworkService.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Foundation
import Network
import Combine

final class NetworkService: NetworkServiceProtocol {
    @Injected var alertService: (any AlertServiceProtocol)?
    
    private let session = {
        let configuration = URLSessionConfiguration.default
        // Ignoring cache to properly check persistence
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    private let networkMonitor = NWPathMonitor()
    private var isConnectionAvailable: Bool { networkMonitor.currentPath.status == .satisfied }
    
    private let _networkAvailablyPublisher = PassthroughSubject<Bool, Never>()
    lazy var networkAvailablyPublisher = _networkAvailablyPublisher.eraseToAnyPublisher()

    // MARK: - Initialization
    init() {
        networkMonitor.pathUpdateHandler = { [weak self] in
            self?._networkAvailablyPublisher.send($0.status == .satisfied)
        }
        networkMonitor.start(queue: .global())
    }
    
    // MARK: - Public
    func fetch(_ endpoint: APIEndpointProtocol) async -> Data? {
        guard isConnectionAvailable else {
            Task { await alertService?.showAlert(for: NetworkServiceError.noConnection) }
            return nil
        }
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
    
    // MARK: - Private
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
