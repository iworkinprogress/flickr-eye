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
    var index = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNotifications()
    }
    
    func configure(with data:FlickrPhotoData?, at index:Int) {
        self.index = index
        if let validData = data {
            self.data = validData
            if let thumbnailURL = validData.thumbnailURL() {
                self.imageView.downloadedFrom(url: thumbnailURL)
            }
        }
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
        self.index = 0
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
                            self.configure(with: photoData, at:self.index)
                        }
                    }
                }
            }
        }
    }
}
