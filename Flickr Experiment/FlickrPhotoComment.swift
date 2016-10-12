//
//  FlickrPhotoComment.swift
//  Flickr Experiment
//
//  Created by Steven Baughman on 10/11/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import UIKit

class FlickrPhotoComment: NSObject {
    
    var author:String!
    var date:Date!
    var comment:String!
    
    init(with dictionary:NSDictionary) {
        super.init()
        if let author = dictionary["realname"] as? String {
            self.author = author
        }
        if author.characters.count == 0 {
            self.author = NSLocalizedString("Unknown", comment: "Unknown author")
        }
        self.comment = dictionary["_content"] as! String
        
        let timestamp = TimeInterval(dictionary["datecreate"] as! String)!
        self.date = Date(timeIntervalSince1970: timestamp)
    }
    
}
