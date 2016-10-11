//
//  FlickrAPI.swift
//  Interesting Flickr Photos
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import UIKit

let kFlickrPhotosPerPage:Int = 100

class FlickrAPI: NSObject {
    
    let kFlickrPath = "https://api.flickr.com/services/rest/?method="
    let kFlickrGetPhotosMethod = "flickr.photos.getRecent"
    let kFlickrGetDetailsMethod = "flickr.photos.getInfo"
    let kFlickrKey = "8617b22260a92e5550bddcdcfec95f7f"
    let kFlickrFormat = "json"
    
    //MARK: - Singleton
    static let shared : FlickrAPI = {
        let instance = FlickrAPI()
        return instance
    }()
    
    //MARK: - Fetch Photos
    func fetchPhotos(page:NSInteger, completion: @escaping (_ photos:[NSDictionary]?) -> Void) {
        if let flickrURL = URL(string: self.path(for:page)) {
            
            URLSession.shared.dataTask(with: flickrURL, completionHandler: { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                        
                        var loadedPhotos = false
                        if let page = json["photos"] as? NSDictionary {
                            if let photos = page["photo"] as? [NSDictionary] {
                                loadedPhotos = true
                                completion(photos)
                            }
                        }
                        if !loadedPhotos {
                            NSLog("Error parsing Flickr JSON: \(json)")
                            completion(nil)
                        }
                    } catch let error as NSError? {
                        NSLog("Error loading Flickr Feed: \(error?.localizedDescription)")
                        completion(nil)
                    }
                }
            }).resume()
        }
    }
    
    //MARK: - Get Details
    func fetchDetails(data:FlickrPhotoData, completion: @escaping (_ photoDetails:NSDictionary?) -> Void) {
        if let flickrURL = URL(string: self.detailsPath(for:data)) {
            
            URLSession.shared.dataTask(with: flickrURL, completionHandler: { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                        
                        if let photo = json["photo"] as? NSDictionary {
                            completion(photo)
                        }
                        
                    } catch let error as NSError? {
                        NSLog("Error loading Flickr Photo Details: \(error?.localizedDescription)")
                        completion(nil)
                    }
                }
            }).resume()
        }
    }
    
    //MARK: - Paths
    func path(for page:NSInteger) -> String {
        var path = "\(kFlickrPath)"
        path += "&method=\(kFlickrGetPhotosMethod)"
        path += "&page=\(page)"
        path += "&per_page=\(kFlickrPhotosPerPage)"
        path += "&api_key=\(kFlickrKey)"
        path += "&format=\(kFlickrFormat)"
        path += "&nojsoncallback=1"
        return path
    }
    
    func detailsPath(for data:FlickrPhotoData) -> String {
        var path = "\(kFlickrPath)"
        path += "&method=\(kFlickrGetDetailsMethod)"
        path += "&photo_id=\(data.id)"
        path += "&api_key=\(kFlickrKey)"
        path += "&format=\(kFlickrFormat)"
        path += "&nojsoncallback=1"
        return path
    }
}
