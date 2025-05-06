//
//  ProfileModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 29.03.24.
//

import UIKit

class ProfileModel: Decodable {
    
    var id = 0
    var isAdmin = false
    var name = ""
    var login = ""
    var color = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case isAdmin
        case name
        case login
        case color
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        isAdmin = try values.decodeIfPresent(Bool.self, forKey: .isAdmin) ?? false
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        login = try values.decodeIfPresent(String.self, forKey: .login) ?? ""
        color = try values.decodeIfPresent(String.self, forKey: .color) ?? ""
    }
}
