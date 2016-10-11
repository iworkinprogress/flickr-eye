//
//  FlickrPhotoCollectionViewCell.swift
//  Interesting Flickr Photos
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import UIKit

class FlickrPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView:UIImageView!
    
    var data:FlickrPhotoData?
    var index = -1 // negative one so that it will never conflict with actual index
    var isZoomedIn:Bool = false
    
    @IBOutlet var topPadding:NSLayoutConstraint!
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var authorLabel:UILabel!
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet var dateLine:UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNotifications()
    }
    
    func configure(with data:FlickrPhotoData?, at index:Int, isZoomedIn:Bool) {
        self.index = index
        if let validData = data {
            self.data = validData
            self.titleLabel.text = validData.title
            if isZoomedIn {
                self.zoomIn()
            } else {
                self.zoomOut()
            }
        }
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
        self.index = -1
    }
    
    func zoomIn() {
        self.isZoomedIn = true
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = .black
        if let imageURL = self.data?.imageURL() {
            self.imageView.downloadedFrom(url: imageURL)
        }
        self.topPadding.constant = self.zoomedInOffset()
        self.scrollView.isScrollEnabled = true
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.contentOffset = CGPoint.zero
        
        self.showLabels()
        
        // Get additional photo details if they don't exist
        if let validData = self.data {
            if validData.hasDetails() {
                self.updateCellLabels()
            } else {
                validData.fetchDetails(completion: { (photoData) in
                    if(photoData == self.data) {
                        // still looking at same photo, update contents
                        self.updateCellLabels()
                    }
                })
            }
        }
    }
    
    func zoomedInOffset() -> CGFloat {
        // Offset height of status bar when zoomed in
        var height = UIApplication.shared.statusBarFrame.size.height
        // also add navigation bar height
        if let rootNavigationVC = self.window?.rootViewController as? UINavigationController {
            height += rootNavigationVC.navigationBar.bounds.size.height
        }
        return height
    }
    
    func zoomOut() {
        self.isZoomedIn = false
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.backgroundColor = UIColor(red: 0.15, green: 0.17, blue: 0.21, alpha: 1.0)
        if let thumbnailURL = self.data?.thumbnailURL() {
            self.imageView.downloadedFrom(url: thumbnailURL)
        }
        self.topPadding.constant = 0
        self.scrollView.isScrollEnabled = false
        self.scrollView.isUserInteractionEnabled = false
        self.scrollView.contentOffset = CGPoint.zero
        self.hideLabels()
    }
    
    //MARK: - Labels
    func updateCellLabels() {
        if let validData = self.data {
            if validData.hasDetails() {
                self.authorLabel.text = "by \(validData.author)"
                self.dateLabel.text = validData.dateAsString()
            }
        }
    }
    
    func hideLabels() {
        self.titleLabel.alpha = 0
        self.authorLabel.alpha = 0
        self.dateLabel.alpha = 0
        self.dateLine.alpha = 0
    }
    
    func showLabels() {
        self.titleLabel.alpha = 1
        self.authorLabel.alpha = 1
        self.dateLabel.alpha = 1
        self.dateLine.alpha = 1
    }
    
    //MARK: - Notifications
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didLoadPhotoData), name: NSNotification.Name(kDidLoadPhotoData), object: nil)
    }
    
    func didLoadPhotoData(notification:Notification) {
        if let userInfo = notification.userInfo {
            if let photoIndex = userInfo[kDidLoadPhotoIndex] as? Int {
                if photoIndex == index {
                    if let photoData = userInfo[kPhotoData] as? FlickrPhotoData {
                        DispatchQueue.main.async() { () -> Void in
                            self.configure(with: photoData, at:self.index, isZoomedIn: self.isZoomedIn)
                        }
                    }
                }
            }
        }
    }
    
}
