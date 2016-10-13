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
    
    enum FlickrMethod:String {
        case recent = "flickr.photos.getRecent"
        case interesting = "flickr.interestingness.getList"
        case details = "flickr.photos.getInfo"
        case comments = "flickr.photos.comments.getList"
    }
    
    let kFlickrPath = "https://api.flickr.com/services/rest/?method="
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
    
    //MARK: - Comments
    func fetchComments(data:FlickrPhotoData, completion: @escaping (_ photoComments:[NSDictionary]?) -> Void) {
        if let flickrURL = URL(string: self.commentsPath(for:data)) {
            URLSession.shared.dataTask(with: flickrURL, completionHandler: { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                        
                        var loadedComments = false
                        if let comments = json["comments"] as? NSDictionary {
                            if let commentsList = comments["comment"] as? [NSDictionary] {
                                loadedComments = true
                                completion(commentsList)
                            }
                        }
                        if !loadedComments {
                            NSLog("Error parsing Flickr Comments JSON: \(json)")
                            completion(nil)
                        }
                        
                    } catch let error as NSError? {
                        NSLog("Error loading Flickr Photo Comments: \(error?.localizedDescription)")
                        completion(nil)
                    }
                }
            }).resume()
        }
    }
    
    //MARK: - Paths
    func path(for method:FlickrMethod) -> String {
        var path = "\(kFlickrPath)"
        path += "&method=\(method.rawValue)"
        path += "&api_key=\(kFlickrKey)"
        path += "&format=\(kFlickrFormat)"
        path += "&nojsoncallback=1"
        return path

    }
    func path(for page:NSInteger) -> String {
        var path = self.path(for:.interesting)
        path += "&page=\(page)"
        path += "&per_page=\(kFlickrPhotosPerPage)"
        path += "&extras=date_taken,owner_name,views,tags,description"
        return path
    }
    
    func detailsPath(for data:FlickrPhotoData) -> String {
        var path = self.path(for:.details)
        path += "&photo_id=\(data.id!)"
        return path
    }
    
    func commentsPath(for data:FlickrPhotoData) -> String {
        var path = self.path(for:.comments)
        path += "&photo_id=\(data.id!)"
        return path
    }
}
