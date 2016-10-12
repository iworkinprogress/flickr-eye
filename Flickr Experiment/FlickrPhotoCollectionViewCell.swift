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
    @IBOutlet var imageViewHeight:NSLayoutConstraint!
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
            self.authorLabel.text = "by \(validData.author!)"
            self.dateLabel.text = validData.dateAsString()
            // unset the image view image
            self.imageView.image = nil
            // and try to download / load one from cache if previously downloaded
            if let imageURL = validData.imageURL() {
                self.imageView.downloadedFrom(url: imageURL)
            }
        }
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
        self.index = -1
    }
    
    func zoomIn(width:CGFloat) {
        self.isZoomedIn = true
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = .black
        if let imageURL = self.data?.imageURL() {
            self.imageView.downloadedFrom(url: imageURL)
        }
        
        // Adjust padding to appear below NavigationBar
        self.topPadding.constant = self.zoomedInOffset()
        
        // Adjust image view to be same aspect ratio of image
        if let image = self.imageView.image {
            let size = image.size
            self.imageViewHeight.constant = width * (size.height / size.width)
        }
        
        // Enable Scroll view incase comments require scrolling
        self.scrollView.isScrollEnabled = true
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.contentOffset = CGPoint.zero
        
        // Get details for this photo if we haven't already
        self.showLabels()
    }
    
    func zoomOut(width:CGFloat) {
        self.isZoomedIn = false
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.backgroundColor = UIColor(red: 0.15, green: 0.17, blue: 0.21, alpha: 1.0)
        if let thumbnailURL = self.data?.thumbnailURL() {
            self.imageView.downloadedFrom(url: thumbnailURL)
        }
        
        // Update padding to be flush with top of screen
        self.topPadding.constant = 0
        
        // make ImageView a square
        if width > 0 {
            self.imageViewHeight.constant = width
        }
        
        // disable scrollview because we're only showing thumbnail when zoomed out
        self.scrollView.isScrollEnabled = false
        self.scrollView.isUserInteractionEnabled = false
        self.scrollView.contentOffset = CGPoint.zero
        
        // Only show image while zoomed out
        self.hideLabels()
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
    
    //MARK: - Labels
    func clearDetailLabels() {
        self.authorLabel.text = ""
        self.dateLabel.text = ""
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
    
    //MARK: - Comments
    func showComments() {
        NSLog("Get comments")
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
