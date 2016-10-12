//
//  FlickrCommentView.swift
//  Flickr Experiment
//
//  Created by Steven Baughman on 10/12/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import UIKit

class FlickrCommentView: UIView {
    
    @IBOutlet var authorLabel:UILabel!
    @IBOutlet var commentLabel:UILabel!
    
    func configure(with data:FlickrPhotoComment) {
        self.authorLabel.text = data.author
        self.commentLabel.text = data.comment
        // Date?
    }
}
