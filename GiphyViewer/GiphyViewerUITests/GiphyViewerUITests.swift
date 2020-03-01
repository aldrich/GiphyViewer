//
//  GiphyViewerUITests.swift
//  GiphyViewerUITests
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest

class GiphyViewerUITests: XCTestCase {

	override func setUp() {
		// In UI tests it is usually best to stop immediately when a failure occurs.
		continueAfterFailure = false

		// In UI tests it’s important to set the initial state -
		// such as interface orientation - required for your tests before they
		// run. The setUp method is a good place to do this.
	}

	func testTapOnACellOnList() {

		let app = XCUIApplication()
		app.launch()

		// tap on an arbitrary cell
		let cell = app.cells["index-3"]
		_ = cell.waitForExistence(timeout: 4.0)

		// capture title on cell
		let cellTitle = cell.label

		cell.tap()

		let navbar = app.navigationBars.firstMatch
		_ = navbar.waitForExistence(timeout: 4.0)

		// title on next screen shows the same title as the GIF tapped from list
		XCTAssertEqual(navbar.identifier, cellTitle)

		let infoLabel = app.staticTexts["info-label"]
		_ = infoLabel.waitForExistence(timeout: 4)

		// info label exists
		print(infoLabel.label)
		XCTAssertEqual(infoLabel.label, "GIF info")
	}
}
