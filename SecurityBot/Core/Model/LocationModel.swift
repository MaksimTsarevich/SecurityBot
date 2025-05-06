//
//  LocationModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 5.12.22.
//

import UIKit

class LocationModel: Decodable {
    
    var free = false
    var flag = ""
    var ip = ""
    var key = ""
    var country = ""
    var isSelected = false
    
    enum CodingKeys: String, CodingKey {
        case free
        case flag
        case ip
        case key
        case country
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        free = try values.decodeIfPresent(Bool.self, forKey: .free) ?? false
        flag = try values.decodeIfPresent(String.self, forKey: .flag) ?? ""
        ip = try values.decodeIfPresent(String.self, forKey: .ip) ?? ""
        key = try values.decodeIfPresent(String.self, forKey: .key) ?? ""
        country = try values.decodeIfPresent(String.self, forKey: .country) ?? ""
    }
}
