//
//  CountryCollectionDataSource.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 13.10.22.
//

import UIKit
protocol CountryCollectionDataSourceDelegate: AnyObject {
    func set(location: LocationModel)
}

class CountryCollectionDataSource: NSObject {
    
    // - Data
    private unowned var collectionView: UICollectionView
    private var lastSelectedIndexPath: Int?
    private var locations: [LocationModel]
    private var currentLocation: LocationModel
    
    // - Delegate
    unowned var delegate: CountryCollectionDataSourceDelegate
    unowned var delegate2: CountryListViewControllerDelegate
    
    init(collectionView: UICollectionView, locations: [LocationModel], delegate: CountryCollectionDataSourceDelegate, delegate2: CountryListViewControllerDelegate, currentLocation: LocationModel) {
        self.collectionView = collectionView
        self.locations = locations
        self.delegate = delegate
        self.delegate2 = delegate2
        self.currentLocation = currentLocation
        super.init()
        configure()
    }
}

// - MARK: -
// - MARK: - UICollectionViewDataSource

extension CountryCollectionDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountryListCollectionViewCell", for: indexPath) as! CountryListCollectionViewCell
        cell.set(countries: locations[indexPath.item])
        cell.selectItem(isSelected: currentLocation.key == locations[indexPath.item].key)
            let isActive = UserDefaultsManager().getBoolValue(data: .premium)
            if !isActive{
                if !locations[indexPath.row].free{
                    cell.isUserInteractionEnabled = false
                    cell.show()
                } else {
                    cell.isUserInteractionEnabled = true
                    cell.hidden()
                }
            } else {
                cell.isUserInteractionEnabled = true
                cell.hidden()
            }
        return cell
    }
    
}

// - MARK: -
// - MARK: - UICollectionViewDelegate

extension CountryCollectionDataSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: 71)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentLocation.key == locations[indexPath.item].key { return }
        currentLocation = locations[indexPath.item]
        collectionView.reloadData()
        let isActive = UserDefaultsManager().getBoolValue(data: .premium)
        if !isActive {
                collectionView.reloadData()
                delegate.set(location: currentLocation)
                delegate2.showBack()
        } else {
            collectionView.reloadData()
            delegate.set(location: currentLocation)
            delegate2.showBack()
        }
    }
}

// MARK: -
// MARK: - Configure

private extension CountryCollectionDataSource {
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}
