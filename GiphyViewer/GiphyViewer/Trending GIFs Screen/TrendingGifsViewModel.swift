//
//  ViewModel.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

class TrendingGifsViewModel {

	enum Constants {
		static let limit = 25
		static let pagesToLoad = 20
	}

	let networking: GiphyAPIClient
	let cache: GIFCache
	
	var selectedGif: ((GifObject) -> Void)?

	// closure that sends the complete list of GIF results (so far) that have
	// returned from the API to the receiver
	var receivedNewGifObjects: (([GifObject]) -> Void)?

	var results = [Int: [GifObject]]()

	var initialPagesToLoad: Int
	var limit: Int

	init(initialPagesToLoad: Int = Constants.pagesToLoad,
		 gifsPerPage: Int = Constants.limit,
		 networking: GiphyAPIClient,
		 cache: GIFCache = .shared) {

		self.networking = networking
		self.cache = cache
		self.initialPagesToLoad = initialPagesToLoad
		self.limit = gifsPerPage
	}

	func fetchInitialData() {
		// initial load pages 0 to 24 (25 items each)
		let range = 0 ..< initialPagesToLoad

		range.forEach { index in
			let offset = index * limit
			
			let isBackground = index > 2
			
			networking.getTrendingGifs(offset: offset, limit: limit, background: isBackground) { [weak self] gifs in
				guard let self = self else { return }
				self.results[index] = gifs
				
				let flattenedGifs = self.flattenedGifsResults
				self.receivedNewGifObjects?(flattenedGifs)
				
				
				// cache the gif objects
				flattenedGifs.forEach { [weak self] gif in
					guard let self = self else { return }
					
					guard !gif.isCached(forUnit: .small, in: self.cache) else {
						return
					}
					guard let url = gif.fixedWidthDownsampledImage?.imageURL else { return }
					
					// maybe background queue?
					// print("downloading gif (fixed width) for id \(cacheKey)")
					self.networking.download(url: url, background: true, completion: { data in
						guard let data = data else { return }
						
						gif.cacheData(data, forUnit: .small, in: self.cache)
					})
				}
				
			}
		}
	}

	/// This will fetch the next page's worth of GIFs.
	func addNextGifObjects() {
		let index = nextIndex()
		let offset = limit * index
		networking.getTrendingGifs(offset: offset) { [weak self] gifs in
			guard let self = self else { return }
			self.results[index] = gifs
			self.receivedNewGifObjects?(self.flattenedGifsResults)
		}
	}

	// gives all GIF objects from results as a flattened array (they're ordered
	// by the page number they were requested from). Sorted by key i.e. offset
	// example: [2: [GIF1, GIF2], 1: [GIF3], 3: [GIF4, GIF5]]
	// result = [GIF3, GIF1, GIF2, GIF4, GIF5]
	private var flattenedGifsResults: [GifObject] {
		return results.sorted { $0.key < $1.key }.flatMap { $0.value }
	}

	private func nextIndex() -> Int {
		guard let last = results.keys.sorted().last else { return 0 }
		return last + 1
	}
}
