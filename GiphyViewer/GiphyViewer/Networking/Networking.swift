//
//  Networking.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

protocol NetworkingService {
	@discardableResult func getTrendingGifs(completion: @escaping ([GifObject]) -> Void) -> URLSessionDataTask
}

final class NetworkingApi: NetworkingService {
	private let session = URLSession.shared
	private let key = "DezIty95T3a2Camo3xwe79KxFlKYN5Lz"

//	https://api.giphy.com/v1/gifs/trending?api_key=DezIty95T3a2Camo3xwe79KxFlKYN5Lz&limit=25&rating=G
	@discardableResult
	func getTrendingGifs(completion: @escaping ([GifObject]) -> Void) -> URLSessionDataTask {
		let request = URLRequest(url: URL(string: "https://api.giphy.com/v1/gifs/trending?api_key=\(key)&limit=25&rating=G")!)
		let task = session.dataTask(with: request) { (data, _, _) in
			DispatchQueue.main.async {
				let decoder = JSONDecoder()
				decoder.keyDecodingStrategy = .convertFromSnakeCase
//				let dateFormatter = DateFormatter()
//				dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//				decoder.dateDecodingStrategy = .formatted(dateFormatter)
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
