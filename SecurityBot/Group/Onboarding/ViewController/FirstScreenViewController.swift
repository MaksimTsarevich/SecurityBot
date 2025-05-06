//
//  ViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 4.10.22.
//

import UIKit

class FirstScreenViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var continueButtonView: UIButton!
    @IBOutlet var pageViews: [UIView]!
    
    // - Constraint
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    
    // - DataSource
    private var dataSource: FirstScreenCollectionDataSource!
    
    // - Data
    private var indexRow = 0
    private var screenModels = [FirstScreenAnimationModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        showLoginScreen()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // - Action
    @IBAction func ContinueButtonAction(_ sender: Any) {
        if indexRow <= 1 {
            collectionView.scrollToItem(at: IndexPath(row: indexRow + 1, section: 0), at: .right, animated: true)
        }
        if indexRow == 2 {
            UserDefaultsManager().setBoolValue(value: true, data: .onboarding)
            dismiss(animated: true)
        }
    }
    
    func showLoginScreen() {
        let navigationController = UINavigationController()
        let vc1 = UIStoryboard(name: "WelcomeScreen", bundle: nil).instantiateInitialViewController() as! WelcomeScreenViewController
        navigationController.viewControllers = [vc1]
        navigationController.navigationBar.tintColor = UIColor(red: 0.286, green: 0.612, blue: 0.643, alpha: 1)
//        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as! LoginViewController
        present(navigationController, animated: true)
    }
}

// MARK: -
// MARK: - Data Source Delegate

extension FirstScreenViewController: FirstScreenCollectionDataSourceDelegate {
    
    func scrollView(numberPage: Int) {
        updatePageViews(indexRow: numberPage)
        indexRow = numberPage
    }
}

// MARK: -
// MARK: - Configure

private extension FirstScreenViewController {
    
    func configure() {
        configureScreens()
        configureDataSource()
        configureConstraint()
        configureButton()
    }
    
    func configureScreens() {
        let firstSC = FirstScreenAnimationModel(title: "ABSOLUTE SECURITY\nFOR YOUR DEVICE", animation: "onbord_1", image: "")
        let secondSC = FirstScreenAnimationModel(title:"FAST OPTIMIZATION\nAND CLEANUP", animation: "onbord_2", image: "ShieldFirstScreen")
        let thirdSC = FirstScreenAnimationModel(title: "SECRET FORDER WITH\nYOUR PERSONAL DATA", animation: "onbord_3", image: "")
        screenModels = [firstSC, secondSC, thirdSC]
    }
    
    func configureDataSource() {
        dataSource = FirstScreenCollectionDataSource(collectionView: collectionView, screenModels: screenModels, delegate: self)
    }
    
    func updatePageViews(indexRow: Int) {
        pageViews.forEach { view in
            view.backgroundColor = UIColor(red: 0.286, green: 0.612, blue: 0.643, alpha: 0.3)
        }
        UIView.transition(with: pageViews[indexRow], duration: 0.3, options: .transitionCrossDissolve) { [weak self] in
            self?.pageViews[indexRow].backgroundColor = UIColor(red: 0.286, green: 0.612, blue: 0.643, alpha: 1)
        }
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.height < 680 {
            collectionViewTopConstraint.constant = 50
        }else if UIScreen.main.bounds.height < 1000 {
            buttonWidthConstraint.constant = UIScreen.main.bounds.width - 50
        }
    }
    
    func configureButton() {
        if UIScreen.main.bounds.height < 680 {
            buttonWidthConstraint.constant = UIScreen.main.bounds.width - 100
            continueButtonView.layer.shadowColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.3).cgColor
            continueButtonView.layer.shadowOpacity = 0.1
            continueButtonView.layer.shadowRadius = 30
            continueButtonView.layer.shadowOffset = CGSize(width: 0, height: 0)
            continueButtonView.layer.shadowPath = UIBezierPath(rect: continueButtonView.bounds).cgPath
            continueButtonView.layer.masksToBounds = false
        } else {
            continueButtonView.layer.shadowColor = UIColor(red: 0.286, green: 0.612, blue: 0.643, alpha: 0.5).cgColor
            continueButtonView.layer.shadowOpacity = 1
            continueButtonView.layer.shadowRadius = 30
            continueButtonView.layer.shadowOffset = CGSize(width: 0, height: 0)
            continueButtonView.layer.shadowPath = UIBezierPath(rect: continueButtonView.bounds).cgPath
            continueButtonView.layer.masksToBounds = false
        }
    }
}

