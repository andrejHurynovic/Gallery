//
//  ServiceLocator+registerDefaultFormulas.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 02.03.2025.
//

extension ServiceLocator {
    static func registerDefaultFormulas() {
        ServiceLocator.shared.register(KeychainService() as KeychainServiceProtocol)
        ServiceLocator.shared.register(ImageCacheService<ImageBox>() as ImageCacheServiceProtocol)
        ServiceLocator.shared.register(AlertService() as AlertServiceProtocol)
        ServiceLocator.shared.register(DataService() as DataServiceProtocol)
        ServiceLocator.shared.register(NetworkService() as NetworkServiceProtocol)
    }
}
