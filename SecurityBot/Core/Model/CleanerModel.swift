//
//  CleanerModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 12.10.22.
//

import Foundation
import UIKit

enum CleanerList: String, CaseIterable {
case duplicatePhoto = "DUPLICATE PHOTOS"
case duplicateContact = "DUPLICATE CONTACTS"
case events = "EVENTS"
case screenshot = "SCREENSHOTS"
    
    var cleanerName: String {
        switch self {
        case .duplicatePhoto:
            return "DUPLICATE PHOTOS"
        case .duplicateContact:
            return "DUPLICATE CONTACTS"
        case .events:
            return "EVENTS"
        case .screenshot:
            return "SCREENSHOTS"
        }
    }
    
    var icon: UIImage? {
        switch self {
            
        case .duplicatePhoto:
            return UIImage(named: "DuplicatePhotoImage")
        case .duplicateContact:
            return UIImage(named: "DuplicateContactImage")
        case .events:
            return UIImage(named: "EventImage")
        case .screenshot:
            return UIImage(named: "ScreenshotImage")
        }
    }
    
    var color: UIColor? {
        
        switch self {
            
        case .duplicatePhoto:
            return UIColor(red: 1, green: 0.302, blue: 0.149, alpha: 1)
        case .duplicateContact:
            return UIColor(red: 1, green: 0.192, blue: 0.478, alpha: 1)
        case .events:
            return UIColor(red: 1, green: 0.765, blue: 0.161, alpha: 1)
        case .screenshot:
            return UIColor(red: 0.728, green: 0.149, blue: 1, alpha: 1)
        }
    }
}
