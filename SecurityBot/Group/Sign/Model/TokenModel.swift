//
//  TokenModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 13.02.24.
//

import UIKit

class TokenModel: Decodable {
    
    var Id = 0
    var Name = ""
    var Book = ""
    var Price = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case book
        case price
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        Id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        Name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        Book = try values.decodeIfPresent(String.self, forKey: .book) ?? ""
        Price = try values.decodeIfPresent(Int.self, forKey: .price) ?? 0
    }
}
