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
    var currentPage:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.collectionViewLayout = self.zoomedOutLayout
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK: - Layouts
    lazy var zoomedInLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:self.view.bounds.size.width, height:self.view.bounds.size.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    lazy var zoomedOutLayout:UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        self.update(layout:layout, width:self.view.bounds.size.width, columns:kPhotoColumns)
        layout.minimumLineSpacing = kPhotoPadding
        layout.minimumInteritemSpacing = kPhotoPadding
        layout.scrollDirection = .vertical
        return layout
    }()
    
    func update(layout:UICollectionViewFlowLayout, width:CGFloat, columns:CGFloat) {
        var width:CGFloat = width - ((columns - 1) * kPhotoPadding)
        width = floor(width / columns)
        layout.itemSize = CGSize(width:width, height:width)
    }
    
    //MARK: - Animations
    func zoomIn() {
        if let collectionView = self.collectionView {
            self.isZoomedIn = true
            collectionView.isPagingEnabled = true
            
            var viewsToAnimate = [UIView]()
            for cell in collectionView.visibleCells {
                if let flickrCell = cell as? FlickrPhotoCollectionViewCell {
                    flickrCell.zoomIn(size:self.zoomedInLayout.itemSize)
                    viewsToAnimate.append(flickrCell)
                }
            }
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                collectionView.collectionViewLayout = self.zoomedInLayout
                for view in viewsToAnimate {
                    view.layoutIfNeeded()
                }
            }, completion: nil)
            
            self.navigationController?.setNavigationBarHidden(self.view.bounds.size.width > self.view.bounds.size.height, animated: true)
            
            self.navigationItem.rightBarButtonItem = self.backButton
            // only show navigation bar if portrait
            
        }
    }
    
    func zoomOut() {
        if let collectionView = self.collectionView {
            self.isZoomedIn = false
            collectionView.isPagingEnabled = false
            
            var viewsToAnimate = [UIView]()
            for cell in collectionView.visibleCells {
                if let flickrCell = cell as? FlickrPhotoCollectionViewCell {
                    flickrCell.zoomOut(width:self.zoomedOutLayout.itemSize.width)
                    viewsToAnimate.append(flickrCell)
                }
            }
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                collectionView.collectionViewLayout = self.zoomedOutLayout
                for view in viewsToAnimate {
                    view.layoutIfNeeded()
                }
            }, completion: nil)
            
            self.navigationItem.rightBarButtonItem = nil
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    //MARK: - Lazy
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
        if self.isZoomedIn {
            cell.zoomIn(size:self.zoomedInLayout.itemSize)
        } else {
            cell.zoomOut(width: self.zoomedOutLayout.itemSize.width)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.collectionView?.cellForItem(at: indexPath) as? FlickrPhotoCollectionViewCell {
            cell.showComments()
        }
        self.zoomIn()
        self.currentPage = CGFloat(indexPath.row)
    }
    
    //MARK: - Scroll View
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(decelerate == false) {
            self.scrollingDidEnd()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollingDidEnd()
    }
    
    func scrollingDidEnd() {
        self.showCommentsForVisibleCells()
        if self.isZoomedIn {
            // Keep track of current position when zoomed to make rotation smoother
            if let collectionView = self.collectionView {
                self.currentPage = floor(collectionView.contentOffset.x / self.view.bounds.size.width)
            }
        }
    }
    
    // MARK: - Cell Manipulation
    func showCommentsForVisibleCells() {
        if self.isZoomedIn {
            for cell in self.collectionView!.visibleCells {
                if let flickrCell = cell as? FlickrPhotoCollectionViewCell {
                    flickrCell.showComments()
                }
            }
        }
    }
    
    func updateConstraintsForVisibleCells(for size:CGSize) {
        if self.isZoomedIn {
            for cell in self.collectionView!.visibleCells {
                if let flickrCell = cell as? FlickrPhotoCollectionViewCell {
                    flickrCell.updateContraints(for:size)
                }
            }
        }
    }
    
    //MARK: - Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.update(layout:self.zoomedOutLayout, width:size.width, columns:kPhotoColumns)
        coordinator.animate(alongsideTransition: { (context) in
            self.zoomedInLayout.itemSize = size
            if self.isZoomedIn {
                self.collectionView?.contentOffset = CGPoint(x:self.currentPage * size.width, y:0)
                self.updateConstraintsForVisibleCells(for: size)
                // Hide navigation bar if zoomed in and landscape
                self.navigationController?.setNavigationBarHidden(size.width > size.height, animated: false)
            } else {
                self.zoomOut()
            }
        }) { (context) in
            if self.isZoomedIn {
                self.showCommentsForVisibleCells()
            }
        }
    }
}

