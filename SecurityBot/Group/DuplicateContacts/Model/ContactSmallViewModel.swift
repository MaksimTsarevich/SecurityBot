//
//  ContactSmallViewModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.11.22.
//

import UIKit
import Contacts

struct ContactsSmallViewModel {
    
    var name: String
    var isSelected: Bool
    var contacts: CNContact
    var size: CGSize

    init(contact: CNContact, isSelected: Bool, contacts: CNContact) {
        self.contacts = contacts
        self.isSelected = isSelected
        name = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
        let width = (UIScreen.main.bounds.width - 18 * 2 - 10) / 2
        size = CGSize(width: width, height: 102)
    }
    
}
