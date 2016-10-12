//
//  Flickr-Experiment-Tests.swift
//  Flickr-Experiment-Tests
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import XCTest

class FlickrExperimentTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testValidFlickrPath() {
        let page = 1
        let path = FlickrAPI.shared.path(for:page)
        let url = URL(string: path)
        XCTAssert(url != nil)
    }
    
    func testLoadFlickrPhotosList() {
        // We need to wait for response from FlickrAPI before deciding if this test passes
        let asyncExpectation = expectation(description: "FlickrAPI fetches a list of interesting photos and runs the callback closure with a valid photos dictionary")

        FlickrAPI.shared.fetchPhotos(page: 1) { (photos) in
            XCTAssert(photos != nil)
            if let photosDictionary = photos {
                for dictionary in photosDictionary {
                    let photoData = FlickrPhotoData(with:dictionary)
                    self.validate(data: photoData)
                }
            } else {
                XCTFail("Flickr API did not return photos dictionary")
            }
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testCreatePhotoDataFromDictionary() {
        let dictionary = ["id" : "123456789", "title" : "Test Title", "secret" : "Test-Secret", "farm" : 10, "server" : "Test-Server", "ownername" : "Steven Baughman", "datetaken" : "1983-08-21 01:23:45"] as [String : Any]
        let photoData = FlickrPhotoData(with: dictionary as NSDictionary)
        
        // Test that FlickrPhotoData has valid values
        self.validate(data: photoData)
    }
    
    func validate(data:FlickrPhotoData) {
        XCTAssert(data.id != nil)
        XCTAssert(data.title != nil)
        XCTAssert(data.secret != nil)
        XCTAssert(data.farm != nil)
        XCTAssert(data.server != nil)
        XCTAssert(data.author != nil)
        XCTAssert(data.date != nil)
        XCTAssert(data.dateAsString() != "Unknown")
        XCTAssert(data.thumbnailURL() != nil)
        XCTAssert(data.imageURL() != nil)
    }
    
}
