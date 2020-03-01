//
//  NetworkingAPI.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

class GiphyAPIClient {

	typealias GifsCompletionBlock = ([GifObject]) -> Void

	let queue: OperationQueue = {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		return queue
	}()

	enum Constants {
		static let apiKey = "DezIty95T3a2Camo3xwe79KxFlKYN5Lz"
		static let urlStrFormat = "https://api.giphy.com/v1/gifs/trending?api_key=%@&offset=%d&limit=%d"
		static let limit = 25
	}

	static func decodeAsTrendingImages(data: Data) -> [GifObject] {
		do {
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			let response = try decoder.decode(GetTrendingImagesResponse.self, from: data)
			return response.data
		} catch {
			print(error)
			return []
		}
	}

	func download(url: URL, completion: @escaping (Data?) -> Void) {
		let session = URLSession(configuration: .default)
		let request = URLRequest(url: url)
		let operation = DataFetchOperation(session: session, request: request,
										   completion: { (data, response, error) -> Void in
											DispatchQueue.main.async {
												completion(data)
											}
		})
		queue.addOperation(operation)
	}

	func getTrendingGifsRequest(offset: Int, limit: Int = Constants.limit) -> URLRequest {
		let urlString = String(format: Constants.urlStrFormat, Constants.apiKey, offset, limit)
		let url = URL(string: urlString)!
		let request = URLRequest(url: url)
		return request
	}

	func getTrendingGifs(offset: Int, limit: Int = Constants.limit,
							   completion: @escaping GifsCompletionBlock) {

		let request = getTrendingGifsRequest(offset: offset, limit: limit)

		let session = URLSession(configuration: .default)

		let operation = DataFetchOperation(session: session, request: request, completion: { (data, _, _) -> Void in
			guard let data = data else { return }
			DispatchQueue.main.async {
				let gifs = GiphyAPIClient.decodeAsTrendingImages(data: data)
				completion(gifs)
			}
		})
		queue.addOperation(operation)
	}
}

class DataFetchOperation: Operation {

	var task: URLSessionTask?

	init(session: URLSession, request: URLRequest,
		 completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)) {
		super.init()
		self.task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
			completion(data, response, error)
			self?.executing(false)
			self?.finish(true)
		})
	}

	override var isFinished: Bool {
		return _finished
	}

	override var isExecuting: Bool {
		return _executing
	}

	private var _executing = false {
		willSet {
			willChangeValue(forKey: "isExecuting")
		}
		didSet {
			didChangeValue(forKey: "isExecuting")
		}
	}

	private var _finished = false {
		willSet {
			willChangeValue(forKey: "isFinished")
		}

		didSet {
			didChangeValue(forKey: "isFinished")
		}
	}

	func executing(_ executing: Bool) {
		_executing = executing
	}

	func finish(_ finished: Bool) {
		_finished = finished
	}

	override func start() {
		task!.resume()
	}

	override func cancel() {
		super.cancel()
		task!.cancel()
	}
}

struct GetTrendingImagesResponse: Decodable {
	let data: [GifObject]
}
