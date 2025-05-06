//
//  ContactSearchManager.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 10.11.22.
//

import UIKit
import Contacts

class ContactSearchManager {
    
    static let shared = ContactSearchManager()
    let contactStore = CNContactStore()
    
    func fetchContacts(completion: @escaping (_ contacts: [CNContact]) -> Void) {
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactImageDataKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactDepartmentNameKey,
            CNContactPhoneticGivenNameKey,
            CNContactPhoneticMiddleNameKey,
            CNContactPhoneticFamilyNameKey,
            CNContactNicknameKey,
            CNContactPreviousFamilyNameKey,
            CNContactJobTitleKey,
            CNContactPostalAddressesKey,
            CNContactUrlAddressesKey,
            CNContactRelationsKey,
            CNContactSocialProfilesKey,
            CNContactBirthdayKey,
            CNContactInstantMessageAddressesKey
        ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                contacts.append(contact)
            }
        } catch {
            print("Unable to fetch contacts")
        }
        
        completion(contacts)
    }
    
    func delete(contacts: [CNContact], completion: @escaping (_ events: [CNContact]) -> Void) {
        for contact in contacts {
            let req = CNSaveRequest()
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            req.delete(mutableContact)
            do {
                try contactStore.execute(req)
            } catch {
                print(error.localizedDescription)
            }
        }
        fetchContacts(completion: completion)
    }
}
