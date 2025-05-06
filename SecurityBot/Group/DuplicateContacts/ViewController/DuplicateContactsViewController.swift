//
//  DuplicateContactsViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import UIKit
import Contacts

class DuplicateContactsViewController: UIViewController {

    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectCountLabel: UILabel!
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var duplicateContactsLabel: UILabel!
    
    // - Constraint
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    
    // - DataSource
    private var dataSource: DuplicateContactsCollectionDataSource!
    
    // - Delegate
    weak var delegate: DuplicateContactsCollectionDataSourceDelegate?
    weak var delegateContact: UpdateDelegate?
    
    // - Data
    var duplicateContacts = [ContactMainViewModel]()
    var selectContact = [CNContact]()
    var contacts = [CNContact]()
    var isPresent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // - Action
    @IBAction func backButtonAction(_ sender: Any) {
        if isPresent {
            delegateContact?.updateContacts(viewModels: duplicateContacts)
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        } else {
            delegateContact?.updateContacts(viewModels: duplicateContacts)
            navigationController?.popViewController(animated: true)
            
        }
    }
    
    @IBAction func cleanButtonAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirm".localized, message: "Are you sure that you want to remove contacts?".localized, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return}
            var index = 0
            for viewModel in strongSelf.duplicateContacts {
                let selectedViewModels = viewModel.viewModels.map({$0.isSelected}).filter({$0})
                let countViewModels = viewModel.viewModels.count
                let countSelect = selectedViewModels.count
                let diff = countViewModels - countSelect
                if diff == 0 || diff == 1 {
                    strongSelf.duplicateContacts.remove(at: index)
                    if strongSelf.duplicateContacts.count == 0 {
                        strongSelf.navigationController?.popViewController(animated: true)
                        strongSelf.delegateContact?.updateContacts(viewModels: strongSelf.duplicateContacts)
                    }
                } else {
                    var n = 0
                    for viewModel in viewModel.viewModels {
                        if viewModel.isSelected {
                            strongSelf.duplicateContacts[index].viewModels.remove(at: n)
                        } else {
                            n += 1
                        }
                    }
                    index += 1
                }
            }
            strongSelf.selectCountLabel.text = "SELECTED 0"
            strongSelf.dataSource.delete(viewModels: strongSelf.duplicateContacts)
            ContactSearchManager.shared.delete(contacts: strongSelf.selectContact) { contacts in
                strongSelf.contacts = contacts
            }
            strongSelf.delegate?.update(viewModels: strongSelf.duplicateContacts)
            strongSelf.delegateContact?.updateContacts(viewModels: strongSelf.duplicateContacts)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
}

// MARK: -
// MARK: - Configure

extension DuplicateContactsViewController: DuplicateContactsCollectionDataSourceDelegate {
    
    func update(viewModels: [ContactMainViewModel]) {
        self.duplicateContacts = viewModels
        configureSelectContact()
    }
    
    func setSelectAll(tag: Int) {
        for i in 0..<duplicateContacts[tag].viewModels.count {
            duplicateContacts[tag].viewModels[i].isSelected = true
            dataSource.update(viewModels: duplicateContacts, indexPath: IndexPath(row: i, section: tag))
        }
        configureSelectContact()
    }
}

// MARK: -
// MARK: - Configure

private extension DuplicateContactsViewController {
    
    func configure() {
        configureDataSource()
        configureConstraint()
        configureSelectContact()
        configureButton()
        configureLabel()
    }
    
    func configureDataSource() {
        dataSource = DuplicateContactsCollectionDataSource(collectionView: collectionView, viewModels: duplicateContacts, delegate: self)
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 1000 {
            collectionViewWidthConstraint.constant = UIScreen.main.bounds.size.width
        }
    }
    
    func configureSelectContact() {
        Cleaner.contact = true
        selectContact = []
        for duplicateContact in duplicateContacts {
            for i in 0..<duplicateContact.viewModels.count {
                if duplicateContact.viewModels[i].isSelected {
                    selectContact.append(duplicateContact.viewModels[i].contact)
                }
            }
        }
        selectCountLabel.text = "SELECTED \(selectContact.count)"
    }
    
    func configureButton() {
        cleanButton.layer.shadowColor = UIColor(red: 1, green: 0.762, blue: 0.149, alpha: 0.3).cgColor
        cleanButton.layer.shadowOpacity = 1
        cleanButton.layer.shadowRadius = 20
        cleanButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        cleanButton.layer.shadowPath = UIBezierPath(rect: cleanButton.bounds).cgPath
        cleanButton.layer.masksToBounds = false
    }
    
    func configureLabel() {
        duplicateContactsLabel.addCharacterSpacing(kernValue: 1.21)
    }
}

