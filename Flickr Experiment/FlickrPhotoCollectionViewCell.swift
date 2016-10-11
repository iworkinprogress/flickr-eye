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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNotifications()
    }
    
    func configure(with data:FlickrPhotoData?, at index:Int, isZoomedIn:Bool) {
        self.index = index
        if let validData = data {
            self.data = validData
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
