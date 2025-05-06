//
//  EventsCollectionViewModelConfigure.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 14.11.22.
//

import UIKit
import EventKit

class EventsCollectionViewModelConfigure {
    
    func configureEventsViewModels(events: [EKEvent]) -> [BigEventsCollectionViewModel] {
        var viewModels = [BigEventsCollectionViewModel]()
        var eventGroupedByDuplicated: [[EKEvent]] = [[EKEvent]]()
        eventGroupedByDuplicated.append(events)
        
        var newEvent = [EKEvent]()
        var finalEvent: [[EKEvent]] = [[EKEvent]]()
        
        for event in events {
            let dupEvents = events.filter({ $0.occurrenceDate == event.occurrenceDate && $0.title == event.title })
            if dupEvents.count > 1 {
                if finalEvent.count > 0 {
                    if let _ = finalEvent.firstIndex(where: {$0.first?.title == dupEvents.first?.title}) {
                    } else {
                        finalEvent.append(dupEvents)
                    }
                } else {
                    finalEvent.append(dupEvents)
                }
            }
        }
        
        for someEvent in finalEvent {
            let vm1 = BigEventsCollectionViewModel(events: someEvent, count: newEvent.count, isSelected: false)
            viewModels.append(vm1)
        }
        return viewModels
    }
}
