//
//  Models.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

struct GifObject: Decodable {
	// not all properties are included.
	// Ref: https://developers.giphy.com/docs/api/schema#gif-object
	let bitlyUrl: String
	let embedUrl: String
	let id: String // unique id
	let images: [String: ImageObject]
	let importDatetime: String
	let rating: String
	let slug: String
	let title: String
	let trendingDatetime: String
	let type: String // "gif"
	let url: String
	let user: UserObject?
	let username: String
}

struct ResponsePagination: Decodable {
	let count: Int
	let offset: Int
	let totalCount: Int
}

struct UserObject: Decodable {
	// TODO: fill in user object
}

struct ImageObject: Decodable {
	// Ref: https://developers.giphy.com/docs/api/schema#image-object
	let frames: String?
	let hash: String?
	let height: String?
	let mp4: String?
	let mp4Size: String?
	let size: String?
	let url: String?
	let webp: String?
	let webpSize: String?
	let width: String?
}
