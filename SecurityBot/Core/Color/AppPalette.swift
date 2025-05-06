//
//  AppPalette.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.03.24.
//

import UIKit

enum AppPalette {
    
    static func white(alpha: CGFloat = 1.0) -> UIColor {
        return color(fromHex: "FFFFFF").withAlphaComponent(alpha)
    }
    
    static func black(alpha: CGFloat = 1.0) -> UIColor {
        return color(fromHex: "000000").withAlphaComponent(alpha)
    }
    
    // - Graph
    static let photo = color(fromHex: "D45232")
    static let video = color(fromHex: "AB35F6")
    static let contact = color(fromHex: "D33A74")
    static let event = color(fromHex: "DEB045")
    static let other = color(fromHex: "282A39")
    static let free = color(fromHex: "3DF645")
    static let system = color(fromHex: "3E7ADF")
    
    static let backgroundMain = color(fromHex: "E1FAFC")
    static let backgroundMain2 = color(fromHex: "499CA4")
}

// MARK: -
// MARK: - Calc color

extension AppPalette {
    
    static func color(fromHex hex: String) -> UIColor {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                       alpha: 1.0)
    }
    
}
