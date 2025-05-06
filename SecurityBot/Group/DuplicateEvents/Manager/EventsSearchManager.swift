//
//  EventsSearchManager.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.11.22.
//

import Foundation
import EventKit

class EventsSearchManager {
    
    static let shared = EventsSearchManager()
    private let eventStore = EKEventStore()
    
    func getEvents(completion: @escaping (_ events: [EKEvent]) -> Void) {
        eventStore.requestAccess(to: .event) {_,_ in
            let end = Date(timeIntervalSinceNow: +4*365*24*3600)
            let now = Date()
            let predicate = self.eventStore.predicateForEvents(withStart: now, end: end, calendars: nil)
            let events = self.eventStore.events(matching: predicate)
            
            DispatchQueue.main.async {
                completion(events)
            }
        }
    }
    
    func delete(events: [EKEvent], completion: @escaping (_ events: [EKEvent]) -> Void) {
            for event in events {
                do {
                    try self.eventStore.remove(event, span: .thisEvent, commit: true)
                } catch {
                    print(error.localizedDescription)
                }
            }
            self.getEvents(completion: completion)
        
    }
    
}
