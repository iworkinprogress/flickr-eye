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

let kFlickrDateFormat = "yyyy-MM-dd HH:mm:ss"

class FlickrPhotoData: NSObject {
    
    var id:String!
    var secret:String!
    var farm:NSNumber!
    var server:String!
    var title:String!
    var author:String!
    
    // Details
    var date:Date?
    var comments = [FlickrPhotoComment]()
    
    // Secondary info
    var authorName:String?
    
    // Dateformatter
    static let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = kFlickrDateFormat
        return formatter
    }()
    
    init(with dictionary:NSDictionary) {
        super.init()
        self.id = dictionary["id"] as! String
        self.title = dictionary["title"] as! String
        self.secret = dictionary["secret"] as! String
        self.farm = dictionary["farm"] as! NSNumber
        self.server = dictionary["server"] as! String
        self.author = dictionary["ownername"] as! String
        if author.characters.count == 0 {
            self.author = NSLocalizedString("Unknown", comment:"Unknown author name")
        }
        
        self.date = FlickrPhotoData.dateFormatter.date(from: dictionary["datetaken"] as! String)
    }
    
    func hasDetails() -> Bool {
        return self.author != nil && self.date != nil
    }
    
    func fetchComments(completion: @escaping (_ data:FlickrPhotoData) -> Void) {
         FlickrAPI.shared.fetchDetails(data: self) { (dictionary) in
            if let validDictionary = dictionary {
                if let comments = validDictionary["comments"] as? [String:AnyObject] {
                    if let commentCount = comments["_content"] as? String {
                        if let count = Int(commentCount) {
                            if count > 0 {
                                NSLog("Load comments")
                            }
                        }
                    }
                }
            }
            completion(self)
        }
    }
    
    func dateAsString() -> String {
        if let validDate = self.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mma MM dd, yyyy"
            return dateFormatter.string(from: validDate)
        } else {
            return NSLocalizedString("Unknown", comment:"Unknown date text")
        }
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
