//
//  CleaningGuideViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 22.10.22.
//

import UIKit

class CleaningGuideViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    
    // - Constraint
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    
    // - DataSource
    private var dataSource: CleaningGuideCollectionDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: -
// MARK: - Delegate

extension CleaningGuideViewController: CleaningGuideViewControllerDelegate {
    func showCleaningGuide(type: WebSites) {
        let webVC = UIStoryboard(name: "WebView", bundle: nil).instantiateInitialViewController() as! WebViewController
        webVC.site = type
        webVC.modalPresentationStyle = .fullScreen
        present(webVC, animated: true)
    }
}

// MARK: -
// MARK: - Configure

private extension CleaningGuideViewController {
    
    func configure() {
        configureDataSource()
        configureConstraint()
    }
    
    func configureDataSource() {
        dataSource = CleaningGuideCollectionDataSource(collectionView: collectionView, delegate: self)
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.height < 1000 {
            collectionViewWidthConstraint.constant = UIScreen.main.bounds.width
        }
    }
    
}

