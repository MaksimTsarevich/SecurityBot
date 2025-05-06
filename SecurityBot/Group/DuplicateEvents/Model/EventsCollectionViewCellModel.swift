//
//  EventsCollectionViewCellModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 14.11.22.
//

import UIKit
import EventKit

struct EventsCollectionViewCellModel {
    var name: String
    var event: EKEvent
    var isSelected: Bool
    var time: String?
    
    init(event: EKEvent, isSelected: Bool) {
        self.event = event
        self.isSelected = isSelected
        name = event.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let formatDate = "\(formatter.string(from: (event.startDate as NSDate) as Date) + " - " + formatter.string(from: (event.endDate as NSDate) as Date)) "
        print(formatDate)
        self.time = formatDate
    }
}
