//
//  ContactMainViewModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.11.22.
//

import UIKit
import Contacts

struct ContactMainViewModel {
    var viewModels: [ContactCollectionViewCellModel]
    var duplicate: String
    var count: Int
    var isSelected: Bool
    
    init(contacts: [CNContact], duplicate: String, count: Int, isSelected: Bool) {
        self.count = contacts.count
        var viewModels = [ContactCollectionViewCellModel]()
        for contact in contacts {
            viewModels.append(ContactCollectionViewCellModel(contact: contact, isSelected: isSelected))
        }
        self.viewModels = viewModels
        self.duplicate = duplicate
        self.isSelected = isSelected
    }
}
