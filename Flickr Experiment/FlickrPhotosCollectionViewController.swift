//
//  FlickrPhotosCollectionViewController.swift
//  Interesting Flickr Photos
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import UIKit

let kPhotoColumns:CGFloat = 3.0
let kPhotoPadding:CGFloat = 1.0
let kFlickrPhotoCellIdentifier = "FlickrPhotoCell"

class FlickrPhotosCollectionViewController: UICollectionViewController {

    let viewModel = FlickrPhotosCollectionViewModel()
    
    let kZoomInSpeed = 0.5
    
    var isZoomedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.collectionViewLayout = self.zoomedOutLayout
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK: - Layouts
    lazy var zoomedInLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    lazy var zoomedOutLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        var width:CGFloat = UIScreen.main.bounds.size.width - ((kPhotoColumns - 1) * kPhotoPadding)
        width = floor(width / kPhotoColumns)
        layout.itemSize = CGSize(width:width, height:width)
        layout.minimumLineSpacing = kPhotoPadding
        layout.minimumInteritemSpacing = kPhotoPadding
        layout.scrollDirection = .vertical
        return layout
    }()
    
    //MARK: - Animations
    func zoomIn() {
        if let collectionView = self.collectionView {
            self.isZoomedIn = true
            collectionView.setCollectionViewLayout(self.zoomedInLayout, animated: true)
            collectionView.isPagingEnabled = true
            for cell in collectionView.visibleCells {
                if let flickrCell = cell as? FlickrPhotoCollectionViewCell {
                    flickrCell.zoomIn()
                }
            }
            self.navigationItem.rightBarButtonItem = self.backButton
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func zoomOut() {
        if let collectionView = self.collectionView {
            self.isZoomedIn = false
            collectionView.setCollectionViewLayout(self.zoomedOutLayout, animated: true)
            collectionView.isPagingEnabled = false
            for cell in collectionView.visibleCells {
                if let flickrCell = cell as? FlickrPhotoCollectionViewCell {
                    flickrCell.zoomOut()
                }
            }
            self.navigationItem.rightBarButtonItem = nil
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    //MARK: - Properties
    lazy var backButton:UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: "Close button title"), style: .plain, target: self, action: #selector(zoomOut))
        barButton.tintColor = .white
        return barButton
    }()
    
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
        cell.configure(with:self.viewModel.data(at:indexPath.row), at:indexPath.row, isZoomedIn: self.isZoomedIn)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.zoomIn()
    }
}

