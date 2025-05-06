//
//  DateExtension.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.11.22.
//

import Foundation

extension Date {
    
    func dateToStringScreenshots() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}
