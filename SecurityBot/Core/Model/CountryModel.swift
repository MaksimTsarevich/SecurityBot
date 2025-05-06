//
//  CountryModel.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.10.22.
//

import Foundation
import UIKit

enum CountryList: String, CaseIterable {
    case usa = "USA"
    case canada = "Canada"
    case singapore = "Singapore"
    case germany = "Germany"
    case india = "India"
    case netherlands = "Netherlands"
    case unitedkingdom = "United Kingdom"
    
    var icon: UIImage? {
        switch self{
        case .usa:
            return UIImage(named: "UsaImage")
        case .canada:
            return UIImage(named: "CanadaImage")
        case .singapore:
            return UIImage(named: "SingaporeImage")
        case .germany:
            return UIImage(named: "GermanyImage")
        case .india:
            return UIImage(named: "IndiaImage")
        case .netherlands:
            return UIImage(named: "NetherlandsImage")
        case .unitedkingdom:
            return UIImage(named: "UnitedKingdomImage")
        }
    }
}



