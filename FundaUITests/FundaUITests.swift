//
//  FundaUITests.swift
//  FundaUITests
//
//  Created by Adam Lovastyik on 15/03/2020.
//  Copyright © 2020 Lovastyik. All rights reserved.
//

import XCTest

class FundaUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStartUI() {

        let app = XCUIApplication()
        app.launch()
    
        XCTAssertTrue(app.navigationBars["main.navbar"].exists)
        XCTAssertTrue(app.textFields["main.textfield.location"].exists)
        XCTAssertTrue(app.staticTexts["main.label.garden"].exists)
        XCTAssertTrue(app.buttons["main.button.search"].exists)
        XCTAssertTrue(app.switches["main.switch.garden"].exists)
        XCTAssertFalse(app.activityIndicators["main.activity.search"].exists)
        XCTAssertFalse(app.progressIndicators["main.progress.search"].exists)
        XCTAssertTrue(app.tables["main.tableview.properties"].exists)
        
        XCTAssertEqual(app.textFields["main.textfield.location"].placeholderValue, NSLocalizedString("Location", comment: "Location placeholder"))
        XCTAssertEqual(app.staticTexts["main.label.garden"].label, NSLocalizedString("with garden", comment: "Garden filter switch title"))
        XCTAssertEqual(app.buttons["main.button.search"].label, NSLocalizedString("Search", comment: "Search button title"))
    }
    
    func testStartWithoutQuery() {
        
        let app = XCUIApplication()
        app.launch()
        
        // On correct touch, button title is supposed to change to "stop"
        app.buttons["main.button.search"].tap()
        XCTAssertEqual(app.buttons["main.button.search"].label, NSLocalizedString("Search", comment: "Search button title"))
    }
    
    func testStartWithQuery() {
        
        let app = XCUIApplication()
        app.launch()
        
        app.textFields["main.textfield.location"].tap()
        app.textFields["main.textfield.location"].typeText("amsterdam")
        app.buttons["main.button.search"].tap()
        XCTAssertEqual(app.buttons["main.button.search"].label, NSLocalizedString("Stop", comment: "Stop button title"))
        XCTAssertTrue(app.activityIndicators["main.activity.search"].exists)
        XCTAssertTrue(app.progressIndicators["main.progress.search"].exists)
        XCTAssertFalse(app.textFields["main.textfield.location"].isEnabled)
        XCTAssertFalse(app.switches["main.switch.garden"].isEnabled)
    }

}
