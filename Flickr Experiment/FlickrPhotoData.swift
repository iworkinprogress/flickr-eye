//
//  FlickrPhotoData.swift
//  Interesting Flickr Photos
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import UIKit

enum PhotoSize {
    case thumbnail
    case large
}

class FlickrPhotoData: NSObject {
    var id:String!
    var secret:String!
    var farm:NSNumber!
    var server:String!
    var title:String!
    
    // Details
    var author:String?
    var date:Date?
//    var comments = [FlickrPhotoComment]()
    
    // Secondary info
    var authorName:String?
    
    init(with dictionary:NSDictionary) {
        super.init()
        self.id = dictionary["id"] as! String
        self.title = dictionary["title"] as! String
        self.secret = dictionary["secret"] as! String
        self.farm = dictionary["farm"] as! NSNumber
        self.server = dictionary["server"] as! String
    }
    
    func hasDetails() -> Bool {
        return author != nil && date != nil
    }
    
    func fetchDetails(completion: @escaping (_ data:FlickrPhotoData) -> Void) {
//        FlickrAPI
    }
    
    func dateAsString() -> String {
        return "9:99am on Saturday, August 21, 2016"
    }
    
    //MARK: - Images
    func thumbnailURL() -> URL? {
        if let path = self.imagePath(size: .thumbnail) {
            return URL(string: path)
        } else {
            return nil
        }
    }
    func imageURL() -> URL? {
        if let path = self.imagePath(size: .large) {
            return URL(string: path)
        } else {
            return nil
        }
    }
    func imagePath(size:PhotoSize) -> String? {
        if self.farm != nil && self.server != nil && self.id != nil && self.secret != nil {
            let sizeSpecifier = size == .thumbnail ? "_n" : "_b"
            return "https://farm\(self.farm!).staticflickr.com/\(self.server!)/\(self.id!)_\(self.secret!)\(sizeSpecifier).jpg"
        } else {
            return nil
        }
    }
    
}
