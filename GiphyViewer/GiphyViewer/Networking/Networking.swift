//
//  Networking.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

//protocol NetworkingService {
//	@discardableResult func getTrendingGifs(limit: Int,
//											completion: @escaping ([GifObject]) -> Void) -> URLSessionDataTask
//}

final class NetworkingApi {
	private let session = URLSession.shared
	private let key = "DezIty95T3a2Camo3xwe79KxFlKYN5Lz"

	@discardableResult
	func getTrendingGifs(offset: Int = 0, limit: Int = 50,
						 completion: @escaping ([GifObject]) -> Void) -> URLSessionDataTask {
		let request = URLRequest(url: URL(string: "https://api.giphy.com/v1/gifs/trending?api_key=\(key)&offset=\(offset)&limit=\(limit)")!)
		let task = session.dataTask(with: request) { (data, _, _) in
			DispatchQueue.main.async {
				let decoder = JSONDecoder()
				decoder.keyDecodingStrategy = .convertFromSnakeCase
				do {
					if let data = data {
						let response = try decoder.decode(GetTrendingImagesResponse.self, from: data)
						completion(response.data) // Good
					}
				} catch {
					print(error) // decoding error likely.
					completion([]) // Bad
				}
			}
		}
		task.resume()
		return task
	}
}

fileprivate struct GetTrendingImagesResponse: Decodable {
	let data: [GifObject]
	let pagination: ResponsePagination
	// meta not used
}
