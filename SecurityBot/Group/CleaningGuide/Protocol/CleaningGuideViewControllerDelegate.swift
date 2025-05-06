//
//  CleaningGuideViewControllerDelegate.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 13.12.22.
//

import Foundation

protocol CleaningGuideViewControllerDelegate: AnyObject {
    func showCleaningGuide(type: WebSites)
}
