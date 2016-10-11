//
//  FlickrPhotosCollectionViewModel.swift
//  Interesting Flickr Photos
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import UIKit

let kDidLoadPhotoData = "DidLoadPhotoData"
let kPhotoData = "PhotoData"
let kDidLoadPhotoIndex = "DidLoadPhotoIndex"

class FlickrPhotosCollectionViewModel: NSObject {
    
    var photoData = [FlickrPhotoData]()
    var pagesLoaded = 0
    
    override init() {
        super.init()
        self.fetchNextPageOfPhotos()
    }
    
    func fetchNextPageOfPhotos() {
        self.pagesLoaded += 1
        FlickrAPI.shared.fetchPhotos(page: self.pagesLoaded) { (photos) in
            if let photoDictionaries = photos {
                for photoDictionary in photoDictionaries {
                    let photoData = FlickrPhotoData(with: photoDictionary)
                    // Notify any visible cells that we've loaded data for this index
                    NotificationCenter.default.post(name: Notification.Name(kDidLoadPhotoData), object: nil, userInfo: [kPhotoData : photoData, kDidLoadPhotoIndex : self.photoData.count])
                    self.photoData.append(photoData)
                }
            } else {
                // Service may be down  or no internet connect
                self.pagesLoaded -= 1
            }
        }
    }
    
    func data(at index:Int) -> FlickrPhotoData? {
        if self.photoData.count > index {
            return self.photoData[index]
        } else {
            // Load more images if our index is past the total loaded attempted
            if self.pagesLoaded * kFlickrPhotosPerPage < index {
                self.fetchNextPageOfPhotos()
            }
            return nil
        }
    }
}
