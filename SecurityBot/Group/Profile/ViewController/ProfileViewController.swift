//
//  ProfileViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 29.03.24.
//

import UIKit
import PanModal

class ProfileViewController: UIViewController {
    
    // - UI
    
    // - Data
    var panScrollable: UIScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: -
// MARK: - Delegate PanModal

extension ProfileViewController: PanModalPresentable {

    var topOffset: CGFloat {
        if UIScreen.main.bounds.height < 570 {
            return 30
        } else {
            return UIScreen.main.bounds.height - 400
        }
    }
    
    var cornerRadius: CGFloat {
        return 15
    }
    
    var showDragIndicator: Bool {
        return true
    }
}
