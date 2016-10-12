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
    
    // Autolayout Constraints
    @IBOutlet var topPadding:NSLayoutConstraint!
    @IBOutlet var imageViewHeight:NSLayoutConstraint!
    @IBOutlet var textViewHeight:NSLayoutConstraint!
    
    // Views
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var authorLabel:UILabel!
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet var viewsLabel:UILabel!
    @IBOutlet var dateLine:UIView!
    @IBOutlet var dateLine2:UIView!
    @IBOutlet var commentsTextView:UITextView!
    
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
            self.viewsLabel.text = "\(validData.views!) views"
            
            // unset the image view image
            self.imageView.image = nil
            
            // and try to download / load one from cache if previously downloaded
            if isZoomedIn {
                if let imageURL = validData.imageURL() {
                    self.downloadedFrom(url: imageURL)
                }
            } else {
                if let imageURL = validData.thumbnailURL() {
                    self.downloadedFrom(url: imageURL)
                }
            }
        }
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
        self.index = -1
    }
    
    //MARK: - Zoom
    func zoomOut(width:CGFloat) {
        self.isZoomedIn = false
        self.imageView.backgroundColor = UIColor(red: 0.15, green: 0.17, blue: 0.21, alpha: 1.0)
        if let thumbnailURL = self.data?.thumbnailURL() {
            self.downloadedFrom(url: thumbnailURL)
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
    
    func zoomIn(size:CGSize) {
        self.isZoomedIn = true
        self.imageView.backgroundColor = .black
        if let imageURL = self.data?.imageURL() {
            self.downloadedFrom(url: imageURL)
        }
        
        // Update Constraints
        self.updateContraints(for: size)
        
        // Enable Scroll view incase comments require scrolling
        self.scrollView.isScrollEnabled = true
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.contentOffset = CGPoint.zero
        
        // Get details for this photo if we haven't already
        self.showLabels()
        
        // Clear out existing comments
        self.clearComments()
    }
    
    func updateContraints(for size:CGSize) {
        // Update top padding to be under the navigation bar if in portrait
        self.updateTopPadding(size:size)
        
        // Adjust image view to be same aspect ratio of image
        self.updateImageSizeToFit(width:size.width, maxHeight:size.height)
    }
    
    func updateTopPadding(size:CGSize) {
        // Adjust padding to appear below NavigationBar
        if size.width > size.height {
            self.topPadding.constant = 0
        } else {
            // Offset height of status bar when zoomed in
            // Should be able to get 20 dynamically..but isn't right value during rotaiton...
            var height:CGFloat = UIApplication.shared.statusBarFrame.size.height
            // also add navigation bar height
            if let rootNavigationVC = self.window?.rootViewController as? UINavigationController {
                height += rootNavigationVC.navigationBar.bounds.size.height
            }
            self.topPadding.constant = height
        }

    }
    
    func updateImageSizeToFit(width:CGFloat, maxHeight:CGFloat) {
        if let image = self.imageView.image {
            let size = image.size
            self.imageViewHeight.constant = min(width * (size.height / size.width), maxHeight)
        }
    }
    
    //MARK: - Labels
    func hideLabels() {
        self.showLabels(show: false)
    }
    
    func showLabels() {
        self.showLabels(show: true)
    }
    
    func showLabels(show:Bool) {
        self.titleLabel.isHidden = !show
        self.authorLabel.isHidden = !show
        self.dateLabel.isHidden = !show
        self.dateLine.isHidden = !show
        self.dateLine2.isHidden = !show
        self.commentsTextView.isHidden = !show
    }
    
    //MARK: - Comments
    func showComments() {
        
        if let validData = self.data {
            // Instead of using a UITextView to display this content
            // We really should use UITableView
            // But that would require restructing our view hierarchy signficantly to make work well
            // For now, lets limit comment display to 8000 height
            if let comments = validData.comments {
                var string = ""
                for comment in comments {
                    string += "\(comment.author!) wrote:\n"
                    string += comment.comment
                    string += "\n\n"
                }
                if string.characters.count == 0 {
                    self.commentsTextView.text = NSLocalizedString("No comments", comment:"Message displayed when there are not comments")
                } else {
                    self.commentsTextView.text = string
                }
                self.textViewHeight.constant = min(self.commentsTextView.sizeThatFits(self.commentsTextView.contentSize).height, 8000)
            } else {
                // Fetch comments
                validData.fetchComments(completion: { (photoData) in
                    if let validData = self.data {
                        if validData.id == photoData.id {
                            DispatchQueue.main.async() { () -> Void in
                                self.showComments()
                            }
                        }
                    }
                })
            }
        }
    }
    
    func clearComments() {
        self.commentsTextView.setContentOffset(CGPoint.zero, animated: false)
        self.commentsTextView.text = NSLocalizedString("Loading comments…", comment:"Message displayed while loading comments")
        self.textViewHeight.constant = self.commentsTextView.sizeThatFits(self.commentsTextView.contentSize).height
    }
    
    //MARK: - Notifications
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didLoadPhotoData), name: NSNotification.Name(kDidLoadPhotoData), object: nil)
    }
    
    func didLoadPhotoData(notification:Notification) {
        if let userInfo = notification.userInfo {
            if let photoIndex = userInfo[kDidLoadPhotoIndex] as? Int {
                if photoIndex == self.index {
                    if let photoData = userInfo[kPhotoData] as? FlickrPhotoData {
                        DispatchQueue.main.async() { () -> Void in
                            self.configure(with: photoData, at:self.index, isZoomedIn: self.isZoomedIn)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Download
    func downloadedFrom(url: URL) {
        if let validData = self.data {
            let currentPhotoID = validData.id
            if let image = ImageCache.shared.image(at: url.absoluteString) {
                self.imageView.image = image
            } else {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    DispatchQueue.main.async() { () -> Void in
                        ImageCache.shared.cache(image: image, at: url.absoluteString)
                        // If we're still using the same data for this cell,
                        // set imageView's image to the downloaded image
                        if let currentData = self.data {
                            if currentPhotoID == currentData.id {
                                self.imageView.image = image
                                if self.isZoomedIn {
                                    // Adjust image view to be same aspect ratio of image
                                    self.updateImageSizeToFit(width:self.imageView.bounds.size.width, maxHeight:self.bounds.size.height)
                                }
                            }
                        }
                    }
                }.resume()
            }
        }
    }
}
