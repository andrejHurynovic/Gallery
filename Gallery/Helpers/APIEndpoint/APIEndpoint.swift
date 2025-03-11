//
//  APIEndpoint.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 03.03.2025.
//

import Foundation

enum APIEndpoint: APIEndpointProtocol {
    case post(id: String)
    
    case posts(page: Int, postsPerPage: Int)
    case postsSearch(page: Int, postsPerPage: Int, query: String)
    
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
        case let .post(id):
            return Constants.baseAPIEndpointURL.appendingPathComponent(APIEndpointConstants.photosPath).appendingPathComponent(id)
        case let .posts(page, postsPerPage):
            return makePostsURL(page: page, postsPerPage: postsPerPage)
        case let .postsSearch(page, postsPerPage, query):
            return makePostsSearchURL(page: page, postsPerPage: postsPerPage, query: query)
        case let .imageDownload(url):
            return URL(string: url)
        case let .imageWithRequirements(requirement):
            return makeImageWithRequirementsURL(requirement)
        }
    }
    
}

private extension APIEndpoint {
    static let postsComponents = URLComponents(url: Constants.baseAPIEndpointURL
        .appendingPathComponent(APIEndpointConstants.photosPath), resolvingAgainstBaseURL: false)!
    static let postsSearchComponents = URLComponents(url: Constants.baseAPIEndpointURL
        .appendingPathComponent(APIEndpointConstants.searchPath)
        .appendingPathComponent(APIEndpointConstants.photosPath), resolvingAgainstBaseURL: false)!
    
    static func queryItems(page: Int, postsPerPage: Int, query: String? = nil) -> [URLQueryItem] {
        var items: [URLQueryItem] = [URLQueryItem(name: APIEndpointConstants.pageQueryItem, value: String(page)),
                                     URLQueryItem(name: APIEndpointConstants.perPageQueryItem, value: String(postsPerPage))]
        if let query { items.append(URLQueryItem(name: APIEndpointConstants.queryQueryItem, value: query)) }
        return items
    }
    
    func makePostsURL(page: Int, postsPerPage: Int) -> URL? {
        var components = Self.postsComponents
        components.queryItems = Self.queryItems(page: page, postsPerPage: postsPerPage)
        return components.url
    }
    
    func makePostsSearchURL(page: Int, postsPerPage: Int, query: String) -> URL? {
        var components = Self.postsSearchComponents
        components.queryItems = Self.queryItems(page: page, postsPerPage: postsPerPage, query: query)
        return components.url
    }
    
    func makeImageWithRequirementsURL(_ requirements: any ImageRequirementsProtocol) -> URL? {
        guard var components = URLComponents(string: requirements.imageURL) else { return nil }
        
        // Use either width or height. If both parameters are specified, the image will be scaled based on the smaller one.
        if requirements.width > requirements.height {
            components.queryItems?.append(URLQueryItem(name: APIEndpointConstants.widthQueryItem,
                                                       value: String(requirements.width)))
        } else {
            components.queryItems?.append(URLQueryItem(name: APIEndpointConstants.heightQueryItem,
                                                       value: String(requirements.height)))
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
