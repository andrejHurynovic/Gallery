//
//  Location+Decodable.swift
//  Gallery
//
//  Created by Andrej Hurynovič on 28.02.2025.
//

import Foundation

extension Location: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        
        let positionContainer = try container.nestedContainer(keyedBy: PositionCodingKeys.self, forKey: .positionContainer)
        self.latitude = try positionContainer.decode(Decimal.self, forKey: .latitude)
        self.longitude = try positionContainer.decode(Decimal.self, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case positionContainer = "position"
    }
    private enum PositionCodingKeys: CodingKey {
        case latitude
        case longitude
    }
}
