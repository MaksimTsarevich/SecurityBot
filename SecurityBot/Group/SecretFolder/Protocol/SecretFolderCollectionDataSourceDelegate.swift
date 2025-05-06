//
//  SecretFolderCollectionDataSourceDelegate.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 29.11.22.
//

import Foundation

protocol SecretFolderCollectionDataSourceDelegate: AnyObject {
    func updateContact(models: [SecretContactModel])
    func updateImage(models: [SecretImageModel])
}
