//
//  HomeViewController.swift
//  MeiPaiDemo
//
//  Created by 陈智颖 on 15/9/29.
//  Copyright © 2015年 YY. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var AssetGridThumbnailSize: CGSize {
        let scale = UIScreen.mainScreen().scale
        let size = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSizeMake(size.width * scale, size.height * scale)
    }
    
    private let model = PhotosModel.shareInstance
    private let numberOfPerRow = 3
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onPhotoUpdated:", name: PhotosModelNotification.photoUpdated, object: nil)
        
        model.getVideoAssetFromPhotoAppWithTargetSize(AssetGridThumbnailSize)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Notification
    func onPhotoUpdated(notificate: NSNotification) {
        collectionView.reloadData()
    }
    
}

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return model.assetAry.count / numberOfPerRow + 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section < model.assetAry.count / numberOfPerRow ? numberOfPerRow : model.assetAry.count - section * numberOfPerRow
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AssetCell", forIndexPath: indexPath) as! VideoCell
        
        model.getVideoImageByAsset(model.assetAry[indexPath.section * numberOfPerRow + indexPath.item]) { image in
            cell.image = image
        }
        
        return cell
    }

}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        model.getVideoAssetByAsset(model.assetAry[indexPath.section * numberOfPerRow + indexPath.item]) { [weak self] asset in
            
            dispatch_async(dispatch_get_main_queue()) {
                let play = PlayViewController.toPlayViewControllerWithAsset(asset)
                self?.navigationController?.pushViewController(play, animated: true)
            }
            
        }
        
    }
    
}

