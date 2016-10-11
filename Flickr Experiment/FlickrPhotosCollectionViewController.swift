//
//  FlickrPhotosCollectionViewController.swift
//  Interesting Flickr Photos
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import UIKit

class FlickrPhotosCollectionViewController: UICollectionViewController {

    let viewModel = FlickrPhotosCollectionViewModel()
    
    let kPhotoColumns:CGFloat = 3.0
    let kPhotoPadding:CGFloat = 1.0
    let kFlickrPhotoCellIdentifier = "FlickrPhotoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set cell size based upon collection view width
        let width:CGFloat = self.collectionView!.bounds.size.width - ((kPhotoColumns - 1) * kPhotoPadding)
        let photoSize = floor(width / kPhotoColumns)
        let flowLayout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width:photoSize, height:photoSize)
        flowLayout.minimumLineSpacing = kPhotoPadding
    }
    
    //MARK: - Memory
    override func didReceiveMemoryWarning() {
        ImageCache.shared.clearCache()
    }

    //MARK: - Collection View
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // ~ Infinite scrolling
        return 999999
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFlickrPhotoCellIdentifier, for: indexPath) as! FlickrPhotoCollectionViewCell
        cell.configure(with:self.viewModel.data(at:indexPath.row), at:indexPath.row)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

