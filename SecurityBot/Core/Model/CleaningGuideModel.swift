//
//  CleaningGuideModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 22.10.22.
//

import Foundation
import UIKit

enum CleanigGuide: String, CaseIterable {
    case offload = "Offload applications\nyou don't use"
    case telegramcache = "Clear Telegram cache"
    case removeWhatsApp = "Remove unnecessary objects\nfrom WhatsApp"
    case viberCleanup = "Make a Viber cleanup"
    case clearAlbum = "Clear the 'Recently Deleted' folder"
    case cleanSafari = "Clean up Safari"
    case deleteApp = "Delete applications\nyou don't use"
    
    var icon: UIImage? {
        switch self{
        
        case .offload:
            return UIImage(named: "OffloadApplicationsIcon")
        case .telegramcache:
            return UIImage(named: "CleanTelegramIcon")
        case .removeWhatsApp:
            return UIImage(named: "RemoveWhatsAppIcon")
        case .viberCleanup:
            return UIImage(named: "ViberCleanIcon")
        case .clearAlbum:
            return UIImage(named: "ClearAlbumIcon")
        case .cleanSafari:
            return UIImage(named: "CleanSafariIcon")
        case .deleteApp:
            return UIImage(named: "DeleteAppIcon")
        }
    }
}
