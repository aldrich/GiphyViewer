//
//  Networking2.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

class NetworkingAPI: NSObject {

	typealias CompletionBlock = ([GifObject], Int) -> Void

	static let queue: OperationQueue = {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1 // they are fetched sequentially
		return queue
	}()

	private static let key = "DezIty95T3a2Camo3xwe79KxFlKYN5Lz"

	static var operation: Operation!

	class func getTrendingGifs(offset: Int, limit: Int = 25, completion: @escaping CompletionBlock) {

		let session = URLSession(configuration: .default)
		let url = URL(string: "https://api.giphy.com/v1/gifs/trending?api_key=\(key)&offset=\(offset)&limit=\(limit)")!
		let request = URLRequest(url: url)

		let operation = FetchOperation(session: session, request: request, completion: { (data, response, error) -> Void in
			DispatchQueue.main.async {
				do {
					if let data = data {
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase

						let response = try decoder.decode(GetTrendingImagesResponse.self, from: data)
						completion(response.data, offset) // Good
					}
				} catch {
					print(error) // decoding error likely.
					completion([], offset) // Bad
				}
			}
		}, offset: offset)

		queue.addOperation(operation)
	}
}

class FetchOperation: Operation {

	var offset: Int?

	var task: URLSessionTask?

	init(session: URLSession, request: URLRequest,
		 completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void), offset: Int) {
		super.init()
		self.task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
			completion(data, response, error)
			self?.executing(false)
			self?.finish(true)
		})
		self.offset = offset
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
		// let url = task?.currentRequest?.url
		task!.resume()
	}

	override func cancel() {
		super.cancel()
		task!.cancel()
	}
}

struct GetTrendingImagesResponse: Decodable {
	let data: [GifObject]
	let pagination: ResponsePagination
	// meta not used
}
