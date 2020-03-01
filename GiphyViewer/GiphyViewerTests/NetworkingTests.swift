//
//  NetworkingTests.swift
//  GiphyViewerTests
//
//  Created by Aldrich Co on 3/1/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest
@testable import GiphyViewer

class NetworkingTests: XCTestCase {
	
	func testRequestCreatedMatchesParameters() {
		let networking = GiphyAPIClient()

		var request = networking.getTrendingGifsRequest(offset: 0, limit: 5)
		
		var expectedUrlString = "https://api.giphy.com/v1/gifs/trending?api_key=DezIty95T3a2Camo3xwe79KxFlKYN5Lz&offset=0&limit=5"
		XCTAssertEqual(request.url?.absoluteString, expectedUrlString)
		
		request = networking.getTrendingGifsRequest(offset: 15)
		expectedUrlString = "https://api.giphy.com/v1/gifs/trending?api_key=DezIty95T3a2Camo3xwe79KxFlKYN5Lz&offset=15&limit=25"
		XCTAssertEqual(request.url?.absoluteString, expectedUrlString)
	}
	
}
