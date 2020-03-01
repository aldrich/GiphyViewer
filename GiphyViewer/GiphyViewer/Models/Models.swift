//
//  Models.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

// Ref: https://developers.giphy.com/docs/api/schema#gif-object
struct GifObject: Decodable {
	let bitlyUrl: String
	let embedUrl: String
	let id: String // unique id
	let images: [String: ImageObject]
	let importDatetime: String
	let title: String
	let trendingDatetime: String
	let url: String
	let username: String
}

// Ref: https://developers.giphy.com/docs/api/schema#image-object
struct ImageObject: Decodable {
	let height: String?
	let width: String?
	let url: String?
	let mp4: String?
	let webp: String?
}

extension GifObject: Equatable {
	static func == (lhs: GifObject, rhs: GifObject) -> Bool {
		return lhs.id == rhs.id
	}
}
