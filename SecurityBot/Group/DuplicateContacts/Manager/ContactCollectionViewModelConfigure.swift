//
//  ContactCollectionViewModelConfigure.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.11.22.
//

import UIKit
import Contacts

class ContactsCollectionViewModelConfigure {
    
    
    func configureContactsViewModels(contacts: [CNContact]) -> [ContactMainViewModel] {
        var viewModels = [ContactMainViewModel]()
        
        var fullNames: [String] = contacts.map { CNContactFormatter.string(from: $0, style: .fullName) ?? "" }
        fullNames.removeAll(where: {$0.isEmpty})
        var contactGroupedByDuplicated: [[CNContact]] = [[CNContact]]()
        let uniqueArray = Array(Set(fullNames))
        var contactGroupedByUnique = [[CNContact]]()
        for fullName in uniqueArray {
            let group = contacts.filter {
                CNContactFormatter.string(from: $0, style: .fullName) == fullName
            }
            contactGroupedByUnique.append(group)
        }
        for items in contactGroupedByUnique{
            if items.count > 1 {
                contactGroupedByDuplicated.append(items)
            }
        }
        
        for contacts in contactGroupedByDuplicated {
            let vm1 = ContactMainViewModel(contacts: contacts, duplicate: "", count: contactGroupedByDuplicated.count, isSelected: false)
            viewModels.append(vm1)
        }

        return viewModels
    }
}
    
private extension ContactsCollectionViewModelConfigure {
    
    func searchDuplicateNames(contacts: [CNContact]) -> [[CNContact]] {
        var fullNames: [String] = contacts.map { CNContactFormatter.string(from: $0, style: .fullName) ?? "" }
        fullNames.removeAll(where: {$0.isEmpty})
        var contactGroupedByDuplicated: [[CNContact]] = [[CNContact]]()
        let uniqueArray = Array(Set(fullNames))
        var contactGroupedByUnique = [[CNContact]]()
        for fullName in uniqueArray {
            let group = contacts.filter {
                CNContactFormatter.string(from: $0, style: .fullName) == fullName
            }
            contactGroupedByUnique.append(group)
        }
        for items in contactGroupedByUnique{
            if items.count > 1 {
                contactGroupedByDuplicated.append(items)
            }
        }
        return contactGroupedByDuplicated
    }
    
    func searchDuplicateNumbers(contacts: [CNContact]) -> [[CNContact]] {
        let numberModels = contacts.map({$0.phoneNumbers})
        var numbers = [String]()
        for phoneNumbers in numberModels {
            numbers += phoneNumbers.map({$0.value.stringValue})
        }
        
        let uniqueArray = Array(Set(numbers))
        var contactGroupedByUnique = [[CNContact]]()
        for number in uniqueArray {
            let group = contacts.filter {
                let phoneNumbers = $0.phoneNumbers
                for num in phoneNumbers {
                    if num.value.stringValue == number {
                        return true
                    }
                }
                return false
            }
            
            if group.count > 1 {
                var exist = false
                
                for i in 0..<contactGroupedByUnique.count {
                    for num in group {
                        if contactGroupedByUnique[i].contains(num) {
                            exist = true
                            var array = contactGroupedByUnique[i]
                            array += group
                            array = Array(Set(array))
                            contactGroupedByUnique[i] = array
                            break
                        }
                    }
                }
                
                if !exist {
                    contactGroupedByUnique.append(group)
                }
            }
        }
        
        return contactGroupedByUnique
    }
    
    func searchDuplicateEmails(contacts: [CNContact]) -> [[CNContact]] {
        let emailsModels = contacts.map({$0.emailAddresses})
        var groups = [[NSString]]()
        for emails in emailsModels {
            groups.append(emails.map({$0.value}))
        }
        
        var contactGroupedByDuplicated: [[CNContact]] = [[CNContact]]()
        let uniqueArray = Array(Set(groups))
        var contactGroupedByUnique = [[CNContact]]()
        for emailGroups in uniqueArray {
            let group = contacts.filter {
                let emails = $0.emailAddresses
                for email in emails {
                    return emailGroups.contains((email.value))
                }
                return false
            }
            contactGroupedByUnique.append(group)
        }
        for items in contactGroupedByUnique {
            if items.count > 1 {
                contactGroupedByDuplicated.append(items)
            }
        }
        return contactGroupedByDuplicated
    }
    
    func searchNoNames(contacts: [CNContact]) -> [[CNContact]] {
        let noNames = contacts.filter {
            let fullName = CNContactFormatter.string(from: $0, style: .fullName) ?? ""
            return fullName.isEmpty
        }
        return [noNames]
    }
    
    func searchNoNumbers(contacts: [CNContact]) -> [[CNContact]] {
        let noNumbers = contacts.filter {
            $0.phoneNumbers.isEmpty
        }
        return [noNumbers]
    }
    
    func mergeAllDuplicates(duplicates: [CNContact]) -> CNMutableContact {
        let newContact = CNMutableContact()
        let contactName = duplicates.first(where: {
            let name = CNContactFormatter.string(from: $0, style: .fullName) ?? ""
            return !name.isEmpty
        })
        
        newContact.namePrefix = contactName?.namePrefix ?? ""
        newContact.nameSuffix = contactName?.nameSuffix ?? ""
        newContact.givenName = contactName?.givenName ?? ""
        newContact.middleName = contactName?.middleName ?? ""
        newContact.familyName = contactName?.familyName ?? ""
        newContact.imageData = duplicates.first(where: {$0.imageData != nil})?.imageData
        newContact.departmentName = duplicates.first(where: {!$0.departmentName.isEmpty})?.departmentName ?? ""
        newContact.organizationName = duplicates.first(where: {!$0.organizationName.isEmpty})?.organizationName ?? ""
        newContact.birthday = duplicates.first(where: {$0.birthday != nil})?.birthday
        newContact.phoneticGivenName = duplicates.first(where: {!$0.phoneticGivenName.isEmpty})?.phoneticGivenName ?? ""
        newContact.nickname = duplicates.first(where: {!$0.nickname.isEmpty})?.nickname ?? ""
        newContact.phoneticMiddleName = duplicates.first(where: {!$0.phoneticMiddleName.isEmpty})?.phoneticMiddleName ?? ""
        newContact.phoneticFamilyName = duplicates.first(where: {!$0.phoneticFamilyName.isEmpty})?.phoneticFamilyName ?? ""
        newContact.previousFamilyName = duplicates.first(where: {!$0.previousFamilyName.isEmpty})?.previousFamilyName ?? ""
        newContact.jobTitle = duplicates.first(where: {!$0.jobTitle.isEmpty})?.jobTitle ?? ""
        
        var phoneNumbers = [CNPhoneNumber: String]()
        var emailAddresses = [NSString: String?]()
        var postalAddresses = [CNPostalAddress: String?]()
        var urlAddresses = [NSString: String?]()
        var contactRelations = [CNContactRelation: String?]()
        var socialProfiles = [CNSocialProfile: String?]()
        var instantMessageAddresses = [CNInstantMessageAddress: String?]()
        
        for duplicate in duplicates {
            for ph in duplicate.phoneNumbers {
                phoneNumbers[ph.value] = ph.label
            }
            for em in duplicate.emailAddresses {
                emailAddresses[em.value] = em.label
            }
            for post in duplicate.postalAddresses {
                postalAddresses[post.value] = post.label
            }
            for url in duplicate.urlAddresses {
                urlAddresses[url.value] = url.label
            }
            for rel in duplicate.contactRelations {
                contactRelations[rel.value] = rel.label
            }
            for soc in duplicate.socialProfiles {
                socialProfiles[soc.value] = soc.label
            }
            for inst in duplicate.instantMessageAddresses {
                instantMessageAddresses[inst.value] = inst.label
            }
        }
        
        for item in phoneNumbers {
            newContact.phoneNumbers.append(CNLabeledValue(label: item.value, value: item.key))
        }
        for item in emailAddresses {
            newContact.emailAddresses.append(CNLabeledValue(label: item.value, value: item.key))
        }
        for item in postalAddresses {
            newContact.postalAddresses.append(CNLabeledValue(label: item.value, value: item.key))
        }
        for item in urlAddresses {
            newContact.urlAddresses.append(CNLabeledValue(label: item.value, value: item.key))
        }
        for item in contactRelations {
            newContact.contactRelations.append(CNLabeledValue(label: item.value, value: item.key))
        }
        for item in socialProfiles {
            newContact.socialProfiles.append(CNLabeledValue(label: item.value, value: item.key))
        }
        for item in instantMessageAddresses {
            newContact.instantMessageAddresses.append(CNLabeledValue(label: item.value, value: item.key))
        }
        
        return newContact
    }
    
}
