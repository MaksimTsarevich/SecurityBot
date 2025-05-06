//
//  ContactCollectionViewCellModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.11.22.
//

import UIKit
import Contacts

struct ContactCollectionViewCellModel {
    var name: String
    var isSelected: Bool
    var contact: CNContact
    var phoneNumber: String
    
    init(contact: CNContact, isSelected: Bool) {
        self.contact = contact
        self.isSelected = isSelected
        name = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
        let number = contact.phoneNumbers.map({$0.value.stringValue})
        self.phoneNumber = number.joined()
        
    }
}


