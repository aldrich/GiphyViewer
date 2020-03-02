//
//  TrendingGifsViewModelTests.swift
//  GiphyViewerTests
//
//  Created by Aldrich Co on 3/1/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest
@testable import GiphyViewer

class TrendingGifsViewModelTests: XCTestCase {

	func testTrendingGifsViewModelInitialFetch() {
		let mockClient = MockGiphyClient()
		let viewModel = TrendingGifsViewModel(initialPagesToLoad: 3,
											  gifsPerPage: 10,
											  networking: mockClient)

		var gifsHistory = [[GifObject]]()
		var timesReceived = 0
		viewModel.receivedNewGifObjects = { gifObjects in
			timesReceived += 1
			gifsHistory.append(gifObjects)
		}

		viewModel.fetchInitialData()

		XCTAssertEqual(timesReceived, 3)
		XCTAssertEqual(gifsHistory.count, 3) // 3 * 10

		// they are given sequentially
		XCTAssertEqual(gifsHistory[0].count, 10)
		XCTAssertEqual(gifsHistory[1].count, 20)
		XCTAssertEqual(gifsHistory[2].count, 30)

		XCTAssertEqual(gifsHistory[0].map { $0.id }, (0..<10).map { "offset-\($0)" })
		XCTAssertEqual(gifsHistory[1].map { $0.id }, (0..<20).map { "offset-\($0)" })
		XCTAssertEqual(gifsHistory[2].map { $0.id }, (0..<30).map { "offset-\($0)" })
	}

	func testTrendingGifsViewModelFetchNextBatchOfItems() {
		let mockClient = MockGiphyClient()
		let viewModel = TrendingGifsViewModel(networking: mockClient)

		var gifsHistory = [[GifObject]]()
		var timesReceived = 0
		viewModel.receivedNewGifObjects = { gifObjects in
			timesReceived += 1
			gifsHistory.append(gifObjects)
		}

		// without calling viewModel.fetchInitialData()
		viewModel.addNextGifObjects()
		XCTAssertEqual(timesReceived, 1)
		XCTAssertEqual(gifsHistory.count, 1)
		XCTAssertEqual(gifsHistory[0].count, 25)
		XCTAssertEqual(gifsHistory[0].map { $0.id }, (0..<25).map { "offset-\($0)" })

		// calling again for another 25
		viewModel.addNextGifObjects()
		XCTAssertEqual(timesReceived, 2)
		XCTAssertEqual(gifsHistory.count, 2)

		XCTAssertEqual(gifsHistory[0].count, 25)
		XCTAssertEqual(gifsHistory[0].map { $0.id }, (0..<25).map { "offset-\($0)" })
		XCTAssertEqual(gifsHistory[1].count, 50)
		XCTAssertEqual(gifsHistory[1].map { $0.id }, (0..<50).map { "offset-\($0)" })
	}
}

class MockGiphyClient: GiphyAPIClient {

	override func getTrendingGifs(offset: Int, limit: Int = Constants.limit, background: Bool = false,
								  completion: @escaping GiphyAPIClient.GifsCompletionBlock) {
		let range = (offset..<offset+limit)
		let mapped = range.map {
			GifObject.with(id: "offset-\($0)")
		}
		completion(mapped)
	}
}

