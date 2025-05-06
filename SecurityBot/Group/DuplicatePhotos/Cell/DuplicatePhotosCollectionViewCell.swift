//
//  DuplicatePhotosCollectionViewCell.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 18.10.22.
//

import UIKit

class DuplicatePhotosCollectionViewCell: UICollectionViewCell {
    
    // - UI
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var selectAllButton: UIButton!
    
    // - DataSource
    //private var dataSource: PhotosCollectionDataSource!
    weak var delegate: DuplicatePhotosCollectionDataSourceDelegate?
    
    // - Data
    private var viewModels = [DuplicatePhotosHorizontalCellCollectionViewModel]()
    var index = 0
    var count = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    
    @IBAction func selectAllButtonAction(_ sender: UIButton) {
        delegate?.selectDuplicate(tag: sender.tag, select: true)
    }
    
    func setupMainCell(viewModels: DuplicatePhotosVerticalCellCollectionViewModel, index: Int) {
        selectAllButton.tag = index
        self.index = index
        self.viewModels = viewModels.duplicatePhotos
        count = viewModels.duplicatePhotos.count - 1
        countLabel.text = "\(count)" + " DUPLICATES"
        collectionView.reloadData()
    }
    
    func selectAll(viewModels: [DuplicatePhotosHorizontalCellCollectionViewModel], select: Bool) {
        self.viewModels = viewModels
        for index in 1..<viewModels.count {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? PhotosCollectionViewCell {
                cell.setSelectedPhoto(isSelected: select)
            }
        }
    }

    func delete(viewModels: [DuplicatePhotosHorizontalCellCollectionViewModel], index: Int) {
        self.index = index
        var indexSmall = 0
        for viewModel in self.viewModels {
            if viewModel.isSelected {
                self.viewModels.remove(at: indexSmall)
                collectionView.deleteItems(at: [IndexPath(row: indexSmall, section: 0)])
                if indexSmall > 0 {
                    indexSmall -= 1
                }
            } else {
                indexSmall += 1
            }
        }
    }
}

// - MARK: -
// - MARK: - Collection Data Source

extension DuplicatePhotosCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModels.count == 2 {
            return viewModels.count + 1
        } else {
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModels.count == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCollectionViewCell", for: indexPath) as! PhotosCollectionViewCell
            if indexPath.row == 2  {
                cell.hidden()
                cell.isUserInteractionEnabled = false
            } else {
                cell.show()
                cell.setupDuplicatePhotoCell(viewModel: viewModels[indexPath.row], isFirst: indexPath.row == 0)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCollectionViewCell", for: indexPath) as! PhotosCollectionViewCell
            cell.show()
            cell.setupDuplicatePhotoCell(viewModel: viewModels[indexPath.row], isFirst: indexPath.row == 0)
            return cell
        }
    }
    
}

// - MARK: -
// - MARK: - Collection Delegate

extension DuplicatePhotosCollectionViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightWidth = (collectionView.frame.height / 2) - 32
        let mainHeightWidth = (collectionView.frame.height) - 50
        if indexPath.row == 0 {
            return CGSize(width: mainHeightWidth, height: mainHeightWidth)
        } else {
            return CGSize(width: heightWidth, height: heightWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        viewModels[indexPath.row].isSelected = !viewModels[indexPath.row].isSelected
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionViewCell {
            cell.setSelectedPhoto(isSelected: viewModels[indexPath.row].isSelected)
        }
        delegate?.selectPhoto(index: IndexPath(row: indexPath.row, section: index) )
    }
}



// - MARK: -
// - MARK: - Configure

private extension DuplicatePhotosCollectionViewCell{
    
    func configure() {
        configureDataSource()
    }
    
    func configureDataSource() {
        collectionView.delegate = self
        collectionView.dataSource = self
//        dataSource = PhotosCollectionDataSource(collectionView: collectionView, delegate: delegate, indexSection: index)
    }
}
