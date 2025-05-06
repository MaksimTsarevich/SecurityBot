//
//  BatteryModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 4.11.22.
//

import UIKit

enum BatteryExtension: String, CaseIterable {
    case lowPower = "Low Power Mode"
    case wifi = "Wi-Fi Refresh"
    case limit = "Limit Notifications"
    case overheating = "Overheating"
    case managing = "Managing Connections"
    case location = "Location Services"
    case batteryUsage = "Battery Usage"
    case backgroundRefresh = "Background Refresh"
    case brightness = "Brightness"
    
    var icon: UIImage? {
        switch self{
        case .lowPower:
            return UIImage(named: "LowPower")
        case .wifi:
            return UIImage(named: "Wifi")
        case .limit:
            return UIImage(named: "LimitNotification")
        case .overheating:
            return UIImage(named: "Overheating")
        case .managing:
            return UIImage(named: "Managing")
        case .location:
            return UIImage(named: "Location")
        case .batteryUsage:
            return UIImage(named: "BatteryUsage")
        case .backgroundRefresh:
            return UIImage(named: "BackgroundRefresh")
        case .brightness:
            return UIImage(named: "Brightness")
        }
    }
}
