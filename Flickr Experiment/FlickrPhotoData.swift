//
//  FlickrPhotoData.swift
//  Interesting Flickr Photos
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import UIKit

enum PhotoSize {
    case square
    case large
}

class FlickrPhotoData: NSObject {
    var id:String!
    var secret:String!
    var farm:NSNumber!
    var server:String!
    var title:String!
    
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
    
    //MARK: - Images
    func thumbnailURL() -> URL? {
        if let path = self.imagePath(size: .square) {
            return URL(string: path)
        } else {
            return nil
        }
    }
    func imagePath(size:PhotoSize) -> String? {
        if self.farm != nil && self.server != nil && self.id != nil && self.secret != nil {
            let sizeSpecifier = size == .square ? "_q" : "_b"
            return "https://farm\(self.farm!).staticflickr.com/\(self.server!)/\(self.id!)_\(self.secret!)\(sizeSpecifier).jpg"
        } else {
            return nil
        }
    }
    
}
