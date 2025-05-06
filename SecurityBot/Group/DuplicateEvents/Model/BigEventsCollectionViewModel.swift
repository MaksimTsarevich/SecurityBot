//
//  BigEventsCollectionViewModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 14.11.22.
//

import UIKit
import EventKit

struct BigEventsCollectionViewModel {
    var viewModels: [EventsCollectionViewCellModel]
    var dateEvent: [String]
    var count: Int
    var isSelected: Bool
    
    
    init(events: [EKEvent], count: Int, isSelected: Bool) {
        self.count = events.count
        var viewModels = [EventsCollectionViewCellModel]()
        var date = [String]()
        for event in events {
            viewModels.append(EventsCollectionViewCellModel(event: event, isSelected: false))
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, y"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            let formatDate = formatter.string(from: (event.startDate as NSDate) as Date).uppercased()
            date.append(formatDate)
            
        }
        self.viewModels = viewModels
        self.isSelected = isSelected
        self.dateEvent = date
    }
}
