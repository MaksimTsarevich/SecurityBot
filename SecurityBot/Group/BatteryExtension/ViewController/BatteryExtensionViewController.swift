//
//  BatteryExtensionViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 4.11.22.
//

import UIKit

class BatteryExtensionViewController: UIViewController {

    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    
    // - Constraint
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    
    
    // - Data
    private var dataSource: BatteryExtensionCollectionDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - Action
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: -
// MARK: - Delegate

extension BatteryExtensionViewController: BatteryExtensionViewControllerDelegate {
    func lowPower(type: WebSites) {
        let webVC = UIStoryboard(name: "WebView", bundle: nil).instantiateInitialViewController() as! WebViewController
        webVC.site = type
        webVC.modalPresentationStyle = .fullScreen
        present(webVC, animated: true)
    }
}

// MARK: -
// MARK: - Configure

private extension BatteryExtensionViewController {
    
    func configure() {
        configureDataSource()
        configureConstraint()
    }
    
    func configureDataSource() {
        dataSource = BatteryExtensionCollectionDataSource(collectionView: collectionView, delegate: self)
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.height < 1000 {
            collectionViewWidthConstraint.constant = UIScreen.main.bounds.width
        }
    }
    
}

