//
//  AccessModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 22.11.22.
//

import UIKit

enum AccessList: String, CaseIterable {
case gallery = "Gallery Access"
case contacts = "Contacts Access"
case events = "Calendar Access"
    
    var subTitle1: String {
        switch self {
        case .gallery:
            return "Gallery access required".uppercased()
        case .contacts:
            return "Contacts Access REQUIRED".uppercased()
        case .events:
            return "CALENDAR Access REQUIRED".uppercased()
        }
    }
    
    var subTitle2: String {
        switch self {
        case .gallery:
            return "Please allow access to your gallery\nin the device settings for full photo scanning"
        case .contacts:
            return "Please allow access to your calendar\nin device settings for full event scanning"
        case .events:
            return "Please allow access to your phonebook\nin device settings for full contact scanning"
        }
    }
    
    var icon: UIImage? {
        switch self {
            
        case .gallery:
            return UIImage(named: "AccessPhotoImage")
        case .contacts:
            return UIImage(named: "AccessContactImage")
        case .events:
            return UIImage(named: "AccessEventImage")
        }
    }
}
