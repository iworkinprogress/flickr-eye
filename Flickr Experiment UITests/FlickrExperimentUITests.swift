//
//  FlickrExperimentUITests.swift
//  Flickr Experiment UITests
//
//  Created by Steven Baughman on 10/10/16.
//  Copyright © 2016 Steven Baughman. All rights reserved.
//

import XCTest

class FlickrExperimentUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTapPhotoAndViewDetails() {
        let app = XCUIApplication()
        let cells = app.collectionViews.cells
        XCTAssert(cells.count > 0)
        
        let collectionView = app.collectionViews.element(boundBy: 0)
        let cell = cells.element(boundBy:0)
        
        // make sure that cell is smaller than collection view
        XCTAssert(cell.frame.size.width < collectionView.frame.size.width)
        
        // Goto details
        cell.tap()
        
        // make sure that cell is equal width with collection view
        XCTAssert(cell.frame.size.width == collectionView.frame.size.width)
        
        // check that the cell has filled in labels with data from Flickr
        let title = app.staticTexts.element(matching: .any, identifier: "Photo Title").label
        XCTAssert(title != "Photo name")
        
        let author = app.staticTexts.element(matching: .any, identifier: "Photo Author").label
        XCTAssert(author != "by Author")
        
        let date = app.staticTexts.element(matching: .any, identifier: "Photo Date").label
        XCTAssert(date != "08/21/1983 @ 4:55pm")
        
        let views = app.staticTexts.element(matching: .any, identifier: "Photo Views").label
        XCTAssert(views != "2478 Views")
        
        let comments = app.textViews.element(matching: .any, identifier: "Photo Comments").value
        XCTAssert(comments as! String != "Comment")
    }
    
}
