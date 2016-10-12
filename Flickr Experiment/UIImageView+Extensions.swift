//
//  UIImageView+Extensions.swift
//  Interesting Flickr Photos
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import Foundation
import UIKit

// @see: http://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift

extension UIImageView {
    func downloadedFrom(url: URL) {
        if let image = ImageCache.shared.image(at: url.absoluteString) {
            self.image = image
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
                    self.image = image
                }
            }.resume()
        }
    }
}
