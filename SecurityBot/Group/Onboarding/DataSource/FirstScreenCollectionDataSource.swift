//
//  FirstScreenCollectionDataSource.swift
//  SecurityBot
//
//  Created by Maks Tsarevich on 13.10.22.
//

import UIKit

protocol FirstScreenCollectionDataSourceDelegate: AnyObject {
    func scrollView(numberPage: Int)
}

class FirstScreenCollectionDataSource: NSObject {
    
    // - UI
    private var collectionView: UICollectionView
    
    // - Delegate
    weak var delegate: FirstScreenCollectionDataSourceDelegate?
    
    // - Data
    private var screenModels: [FirstScreenAnimationModel]
    
    init(collectionView: UICollectionView, screenModels: [FirstScreenAnimationModel], delegate: FirstScreenCollectionDataSourceDelegate) {
        self.collectionView = collectionView
        self.screenModels = screenModels
        self.delegate = delegate
        super.init()
        configure()
    }
}

// MARK: -
// MARK: - UICollectionViewDataSource

extension FirstScreenCollectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FirstCellView", for: indexPath) as! FirstCellView
        cell.set(screen: screenModels[indexPath.item])
        cell.configureObserver()
        return cell
    }
    
}

// MARK: -
// MARK: - UICollectionViewDelegate

extension FirstScreenCollectionDataSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let numberPage = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
        delegate?.scrollView(numberPage: numberPage)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let lottieCell = cell as? FirstCellView else {
            return
        }
        
        // Проверяем, что ячейка действительно видна на экране
        if collectionView.bounds.intersects(lottieCell.frame) {
            // Пример: запустить анимацию Lottie для каждой видимой ячейки
//            lottieCell.animationView.animation = Animation.named("your_animation_file_name")
            lottieCell.animationView.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let lottieCell = cell as? FirstCellView else {
            return
        }
        
        // Остановить анимацию при скрытии ячейки
        lottieCell.animationView.stop()
    }
    
}

// MARK: -
// MARK: - Configure

private extension FirstScreenCollectionDataSource {
    
    func configure() {
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}
