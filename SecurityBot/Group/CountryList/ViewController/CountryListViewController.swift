//
//  CountryListViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 11.10.22.
//

import Foundation
import UIKit

class CountryListViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var trialView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleUnlockLabel: UILabel!
    
    // - Constraint
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    
    
    // - Data
    private var dataSource: CountryCollectionDataSource!
    var locations = [LocationModel]()
    private let locationManager = GetLocation()
    var currentLocation = LocationModel()
    
    // - Delegate
    weak var delegate: CountryCollectionDataSourceDelegate?
    weak var delegate2: CountryListViewControllerDelegate?
//    weak var delegateUpdate: VpnSettinsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    @IBAction func startTrialAction(_ sender: Any) {
//        let shopVC = UIStoryboard(name: "FirstShoppingBasket", bundle: nil).instantiateInitialViewController() as! FirstShoppingBasketViewController
//        shopVC.modalPresentationStyle = .fullScreen
//        shopVC.delegate = self
//        present(shopVC, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        dismiss(animated: true)
        //delegateUpdate?.update(location: currentLocation)
    }
}

// MARK: -
// MARK: - Delegate

extension CountryListViewController: CountryListViewControllerDelegate {
    func updateUI() {
        collectionView.reloadData()
        trialView.isHidden = true
        collectionViewBottomConstraint.constant = 5
    }
    
    func showBack() {
        dismiss(animated: true)
//        delegateUpdate?.update(location: currentLocation)
    }
}

// - MARK: -
// - MARK: - Configure

private extension CountryListViewController {
    
    func configure() {
        configureConstraint()
        configureView()
        configureDataSource()
        checkPay()
        configureLabel()
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.height < 1000 {
            collectionViewWidthConstraint.constant = UIScreen.main.bounds.width
        } else {
            collectionViewWidthConstraint.constant = 580
        }
    }
    
    func configureView() {
//        collectionView.backgroundColor = UIColor(red: 0.035, green: 0.039, blue: 0.078, alpha: 1)
    }
    
    func configureDataSource() {
        dataSource = CountryCollectionDataSource(collectionView:collectionView, locations: locations, delegate: delegate!, delegate2: self, currentLocation: currentLocation)
    }
    
    func checkPay() {
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
            trialView.isHidden = false
        } else {
            trialView.isHidden = true
            collectionViewBottomConstraint.constant = 5
        }
    }
    
    func configureLabel() {
        titleLabel.addCharacterSpacing(kernValue: 2.5)
        subTitleUnlockLabel.addCharacterSpacing(kernValue: 0.5)
    }
}



