//
//  Awesome_Movie_AppUITests.swift
//  Awesome Movie AppUITests
//
//  Created by Michal Ziman on 16/02/2017.
//  Copyright © 2017 Michal Ziman. All rights reserved.
//

import XCTest

class Awesome_Movie_AppUITests: XCTestCase {
        
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
    
    func testExampleEndToEndForFilter() {
        // Just an experimental example
        // Mind you have internet connection!
        
        let app = XCUIApplication()
        
        // Go to filter
        app.navigationBars["Popular Movies"].buttons["Filter"].tap()
        
        // Play a bit with range
        let tablesQuery = app.tables
        tablesQuery.staticTexts["1890"].tap()
        tablesQuery.pickerWheels["1890"].swipeUp()
        
        tablesQuery.staticTexts["2017"].tap()
        tablesQuery.pickerWheels["2017"].swipeDown()

        // Return to Popular table
        app.navigationBars["Filter"].buttons["Popular"].tap()
        
        // Check that Star Wars movie is here
        XCTAssertNotNil(tablesQuery.cells.staticTexts["Star Wars"], "Star Wars should be visible.")
    }
    
}
