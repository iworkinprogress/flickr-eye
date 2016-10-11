//
//  ImageCache.swift
//  Interesting Flickr Photos
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import UIKit

class ImageCache: NSObject {

    var images = [String:UIImage]()
    
    //MARK: - Singleton
    static let shared : ImageCache = {
        let instance = ImageCache()
        return instance
    }()
    
    //MARK: - Cache
    func image(at path:String) -> UIImage? {
        if let image = self.images[path] {
            return image
        } else {
            return nil
        }
    }
    func cache(image:UIImage, at path:String) {
        images[path] = image
    }
    
    func clearCache() {
        self.images = [String:UIImage]()
    }
}
