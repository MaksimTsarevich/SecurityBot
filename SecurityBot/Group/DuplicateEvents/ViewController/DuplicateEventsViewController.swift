//
//  DuplicateEventsViewController.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import UIKit
import EventKit

class DuplicateEventsViewController: UIViewController {

    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectCountLabel: UILabel!
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var eventsLabel: UILabel!
    
    
    // - Constraint
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    
    // - DataSource
    private var dataSource: DuplicateEventsCollectionDataSource!
    
    // - Delegate
    weak var delegate: DuplicateEventsCollectionDataSourceDelegate?
    weak var delegateUpdate: UpdateDelegate?
    
    // - Data
    var viewModelsConfigure = EventsCollectionViewModelConfigure()
    var duplicateEvents = [BigEventsCollectionViewModel]()
    var events = [EKEvent]()
    var selectEvents = [EKEvent]()
    var selectCount = 0
    var isPresent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // - Action
    @IBAction func cleanAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirm".localized, message: "Are you sure that you want to remove events?".localized, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return}
            var index = 0
            for viewModel in strongSelf.duplicateEvents {
                let selectedViewModels = viewModel.viewModels.map({$0.isSelected}).filter({$0})
                let countViewModels = viewModel.viewModels.count
                let countSelect = selectedViewModels.count
                let diff = countViewModels - countSelect
                if diff == 0 || diff == 1 {
                    strongSelf.duplicateEvents.remove(at: index)
                    if strongSelf.duplicateEvents.count == 0 {
                        DispatchQueue.main.async {
                            strongSelf.navigationController?.popViewController(animated: true)
                            strongSelf.delegateUpdate?.updateEvents(viewModels: strongSelf.duplicateEvents)
                        }
                    }
                } else {
                    var n = 0
                    for viewModel in viewModel.viewModels {
                        if viewModel.isSelected {
                            strongSelf.duplicateEvents[index].viewModels.remove(at: n)
                        } else {
                            n += 1
                        }
                    }
                    index += 1
                }
            }
            strongSelf.selectCountLabel.text = "SELECTED 0"
            strongSelf.dataSource.delete(viewModels: strongSelf.duplicateEvents)
            EventsSearchManager.shared.delete(events: strongSelf.selectEvents) { events in
                strongSelf.events = events
            }
            strongSelf.delegate?.update(viewModels: strongSelf.duplicateEvents)
            strongSelf.delegateUpdate?.updateEvents(viewModels: strongSelf.duplicateEvents)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        present(alertController, animated: true)
        
        
    }
    @IBAction func backButtonAction(_ sender: Any) {
        if isPresent {
            delegateUpdate?.updateEvents(viewModels: duplicateEvents)
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        } else {
            delegateUpdate?.updateEvents(viewModels: duplicateEvents)
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: -
// MARK: - Configure

extension DuplicateEventsViewController: DuplicateEventsCollectionDataSourceDelegate {
    func update(viewModels: [BigEventsCollectionViewModel]) {
        self.duplicateEvents = viewModels
        configureSelectEvents()
    }
    
    func setSelectAllEvents(tag: Int) {
        for i in 0..<duplicateEvents[tag].viewModels.count{
            duplicateEvents[tag].viewModels[i].isSelected = true
            dataSource.update(viewModels: duplicateEvents, indexPath: IndexPath(row: i, section: tag))
        }
        configureSelectEvents()
    }
}
// MARK: -
// MARK: - Configure

private extension DuplicateEventsViewController {
    
    func configure() {
        configureDataSource()
        configureConstraint()
        configureSelectEvents()
        configureButton()
        configureLabel()
    }
    
    func configureDataSource() {
        dataSource = DuplicateEventsCollectionDataSource(collectionView: collectionView, viewModels: duplicateEvents, delegate: self)
    }
    
    func configureConstraint() {
        if UIScreen.main.bounds.size.height < 1000 {
            collectionViewWidthConstraint.constant = UIScreen.main.bounds.size.width
        }
    }
    
    func configureSelectEvents() {
        Cleaner.event = true
        selectEvents = []
        for duplicateEvent in duplicateEvents {
            for i in 0..<duplicateEvent.viewModels.count {
                if duplicateEvent.viewModels[i].isSelected {
                    selectEvents.append(duplicateEvent.viewModels[i].event)
                }
            }
        }
        selectCount = selectEvents.count
        selectCountLabel.text = "SELECTED \(selectEvents.count)"
        print(selectEvents)
        print("-------------------------")
    }
    
    func configureViewModels() {
        duplicateEvents = viewModelsConfigure.configureEventsViewModels(events: events)
        //collectionView.reloadData()
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
        eventsLabel.addCharacterSpacing(kernValue: 1.21)
    }
}

