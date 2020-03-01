//
//  GifDetailViewModelTests.swift
//  GiphyViewerTests
//
//  Created by Aldrich Co on 3/1/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest
@testable import GiphyViewer

class GifDetailViewModelTests: XCTestCase {

    func testGetInfoEmptyDate() {
		let gif = GifObject.with(id: "id1")
		let viewModel = GifDetailViewModel.init(gif: gif,
												networking: MockGiphyClient())
		XCTAssertEqual(viewModel.getUploadInfo(), "Uploaded on ")
    }

	func testGetInfoInvalidDateNoUsername() {
		// format of date not recognized: it will use whatever is the date string
		// given
		let gif = GifObject.with(id: "id1", date: "2009-29-11 11:12:34")
		let viewModel = GifDetailViewModel.init(gif: gif,
												networking: MockGiphyClient())
		XCTAssertEqual(viewModel.getUploadInfo(), "Uploaded on 2009-29-11 11:12:34")
    }

	func testGetInfoValidDateNoUsername() {
		let gif = GifObject.with(id: "id1", date: "2019-12-03 15:47:14")
		let viewModel = GifDetailViewModel.init(gif: gif,
												networking: MockGiphyClient())
		XCTAssertEqual(viewModel.getUploadInfo(), "Uploaded on December 03 2019, 3:47 PM")
    }

	func testGetInfoValidDateWithUsername() {
		let gif = GifObject.with(id: "id1", date: "2019-12-04 15:47:14", username: "max")
		let viewModel = GifDetailViewModel.init(gif: gif,
												networking: MockGiphyClient())
		XCTAssertEqual(viewModel.getUploadInfo(), "Uploaded December 04 2019, 3:47 PM by max")
    }
}
