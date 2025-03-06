//
//  APIEndpoint.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Foundation

enum APIEndpoint: APIEndpointProtocol {
    case photo(id: String)
    
    case photos(page: Int, photosPerPage: Int)
    case photosSearch(page: Int, photosPerPage: Int, query: String)
    
    case imageDownload(url: String)
    case imageWithRequirements(_ requirements: any ImageRequirementsProtocol)
    
    var request: URLRequest? {
        @Injected var keychainManager: KeychainServiceProtocol?
        
        guard let url = self.url,
              let keychainManager,
              let apiKey = keychainManager.apiKey else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue(APIEndpointConstants.authorizationPrefix + apiKey, forHTTPHeaderField: APIEndpointConstants.authorizationHeader)
        return request
    }
    
    private var url: URL? {
        switch self {
        case let .photo(id):
            return Constants.baseAPIEndpointURL.appendingPathComponent(APIEndpointConstants.photosPath).appendingPathComponent(id)
        case let .photos(page, photosPerPage):
            return makePhotosURL(page: page, photosPerPage: photosPerPage)
        case let .photosSearch(page, photosPerPage, query):
            return makePhotosSearchURL(page: page, photosPerPage: photosPerPage, query: query)
        case let .imageDownload(url):
            return URL(string: url)
        case let .imageWithRequirements(requirement):
            return makeImageWithRequirementsURL(requirement)
        }
    }
    
}

private extension APIEndpoint {
    static let photosComponents = URLComponents(url: Constants.baseAPIEndpointURL
        .appendingPathComponent(APIEndpointConstants.photosPath), resolvingAgainstBaseURL: false)!
    static let photosSearchComponents = URLComponents(url: Constants.baseAPIEndpointURL
        .appendingPathComponent(APIEndpointConstants.searchPath)
        .appendingPathComponent(APIEndpointConstants.photosPath), resolvingAgainstBaseURL: false)!
    
    static func queryItems(page: Int, photosPerPage: Int, query: String? = nil) -> [URLQueryItem] {
        var items: [URLQueryItem] = [URLQueryItem(name: APIEndpointConstants.pageQueryItem, value: String(page)),
                                     URLQueryItem(name: APIEndpointConstants.perPageQueryItem, value: String(photosPerPage))]
        if let query { items.append(URLQueryItem(name: APIEndpointConstants.queryQueryItem, value: query)) }
        return items
    }
    
    func makePhotosURL(page: Int, photosPerPage: Int) -> URL? {
        var components = Self.photosComponents
        components.queryItems = Self.queryItems(page: page, photosPerPage: photosPerPage)
        return components.url
    }
    
    func makePhotosSearchURL(page: Int, photosPerPage: Int, query: String) -> URL? {
        var components = Self.photosSearchComponents
        components.queryItems = Self.queryItems(page: page, photosPerPage: photosPerPage, query: query)
        return components.url
    }
    
    func makeImageWithRequirementsURL(_ requirements: any ImageRequirementsProtocol) -> URL? {
        guard var components = URLComponents(string: requirements.imageURL) else { return nil }
        
        // Use either width or height. If both parameters are specified, the image will be scaled based on the smaller one.
        if requirements.requiredWidth > requirements.requiredHeight {
            components.queryItems?.append(URLQueryItem(name: APIEndpointConstants.widthQueryItem,
                                                       value: String(requirements.requiredWidth)))
        } else {
            components.queryItems?.append(URLQueryItem(name: APIEndpointConstants.heightQueryItem,
                                                       value: String(requirements.requiredHeight)))
        }
        
        return components.url
    }
}

private extension APIEndpoint {
    struct APIEndpointConstants {
        static let authorizationHeader = "Authorization"
        // Must contain one space after Client-ID
        static let authorizationPrefix = "Client-ID "
        
        static let pageQueryItem = "page"
        static let perPageQueryItem = "per_page"
        static let queryQueryItem = "query"
        
        static let widthQueryItem = "w"
        static let heightQueryItem = "h"

        static let photosPath = "photos"
        static let searchPath = "search"
    }
}
