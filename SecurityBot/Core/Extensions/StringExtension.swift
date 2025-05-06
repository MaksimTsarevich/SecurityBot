//
//  StringExtension.swift
//  PuzzleCleaner
//
//  Created by Archi Morandini on 20.05.2022.
//

import UIKit

extension String {
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

}
