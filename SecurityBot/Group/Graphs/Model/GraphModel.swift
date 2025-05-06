//
//  GraphModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.03.24.
//

import UIKit

struct GraphModel {
    var type: GraphType
    var percent: Float
}

enum GraphType: String, CaseIterable {
    case photo = "Photo"
    case video = "Video"
    case events = "Events"
    case contacts = "Contacts"
    case free = "Free"
    case other = "Other"
    case system = "System"
    
    var color: UIColor {
        switch self {
        case .photo:
            return AppPalette.photo
        case .video:
            return AppPalette.video
        case .events:
            return AppPalette.event
        case .contacts:
            return AppPalette.contact
        case .free:
            return AppPalette.free
        case .other:
            return AppPalette.other
        case .system:
            return AppPalette.system
        }
    }
}
