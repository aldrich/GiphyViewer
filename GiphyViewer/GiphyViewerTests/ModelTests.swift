//
//  ModelTests.swift
//  GiphyViewerTests
//
//  Created by Aldrich Co on 3/1/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest
@testable import GiphyViewer

class ModelTests: XCTestCase {

	func testSampleTrendingResponseDecodedCorrectly() {
		// compare results with trending-sample-response.json in the unit
		// tests bundle
		let sampleData = dataFromJSON("trending-sample-response")
		let gifs = GiphyAPIClient.decodeAsTrendingImages(data: sampleData)
		XCTAssertEqual(gifs.count, 25)
	}

	func testGifJSONObjectDecodedCorrectly() {
		// compare results with gif1.json in the unit tests bundle
		let sampleData = dataFromJSON("gif1")

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		let gif = try! decoder.decode(GifObject.self, from: sampleData)

		XCTAssertEqual(gif.id, "KFhv3T1seYSJuak8TN")
		XCTAssertEqual(gif.fixedWidthDownsampledImage?.url, "https://media3.giphy.com/media/KFhv3T1seYSJuak8TN/200w_d.gif?cid=ffd6e3b7b68a3865a41dbbcab9528ba1ac3aa74b19f7c801&rid=200w_d.gif")
		XCTAssertEqual(gif.fixedWidthStillImage?.url, "https://media3.giphy.com/media/KFhv3T1seYSJuak8TN/200w_s.gif?cid=ffd6e3b7b68a3865a41dbbcab9528ba1ac3aa74b19f7c801&rid=200w_s.gif")
		XCTAssertEqual(gif.fullScreenGifImage?.url, "https://media3.giphy.com/media/KFhv3T1seYSJuak8TN/giphy.gif?cid=ffd6e3b7b68a3865a41dbbcab9528ba1ac3aa74b19f7c801&rid=giphy.gif")
		XCTAssertEqual(gif.originalImage?.url, "https://media3.giphy.com/media/KFhv3T1seYSJuak8TN/giphy.gif?cid=ffd6e3b7b68a3865a41dbbcab9528ba1ac3aa74b19f7c801&rid=giphy.gif")
		XCTAssertEqual(gif.importDatetime, "2020-02-20 15:43:35")
		XCTAssertEqual(gif.title, "Nintendo Switch GIF")
		XCTAssertEqual(gif.username, "")
	}

	private func dataFromJSON(_ name: String) -> Data {
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: name, withExtension: "json")!
		return try! Data.init(contentsOf: url)
	}
}
