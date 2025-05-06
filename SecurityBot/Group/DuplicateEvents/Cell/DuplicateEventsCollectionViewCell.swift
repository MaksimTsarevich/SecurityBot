//
//  DuplicateEventsCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 19.10.22.
//

import UIKit

class DuplicateEventsCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var selectEventImage: UIImageView!
    
    var viewModels = [EventsCollectionViewCellModel]()
    
    weak var delegate: (DuplicateEventsCollectionDataSourceDelegate)?
    
    func setupEvent(viewModel: EventsCollectionViewCellModel) {
        eventNameLabel.text = viewModel.name
        timeLabel.text = viewModel.time
        selectEventImage.image = UIImage(named: viewModel.isSelected ? "Active" : "notActive")
    }
    
    func setSelectedEven(isSelected: Bool) {
        selectEventImage.image = UIImage(named: isSelected ? "Active" : "notActive")
        //delegate?.update(viewModels: viewModels)
    }
    
    func selectAllEvents(viewModels: [EventsCollectionViewCellModel]) {
        self.viewModels = viewModels
        for _ in 0..<viewModels.count{
            setSelectedEven(isSelected: true)
        }
    }
}
