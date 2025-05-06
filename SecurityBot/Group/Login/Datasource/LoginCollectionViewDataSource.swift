//
//  LoginCollectionViewDataSource.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 12.02.24.
//

import UIKit

class LoginCollectionViewDataSource: NSObject {
    
    // - Data
    private unowned var collectionView: UICollectionView
    private var data: [DataModel]
    
    init(collectionView: UICollectionView, data: [DataModel]) {
        self.collectionView = collectionView
        self.data = data
        super.init()
        configure()
    }
    
    func update(data: [DataModel]) {
        self.data = data
        collectionView.reloadData()
    }
}

// - MARK: -
// - MARK: - UICollectionViewDataSource

extension LoginCollectionViewDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoginCollectionViewCell", for: indexPath) as! LoginCollectionViewCell
        cell.setup(data[indexPath.item])
        return cell
    }
    
}

// - MARK: -
// - MARK: - UICollectionViewDelegate

extension LoginCollectionViewDataSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 71)
    }
}

// MARK: -
// MARK: - Configure

private extension LoginCollectionViewDataSource {
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}
