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

	var selectedGif: ((GifObject) -> Void)?

	var receivedNewGifObjects: (([GifObject]) -> Void)?

	var results = [Int: [GifObject]]()

	init() {
		// initial load pages 0 to 24 (25 items each)
		let range = 0 ..< Constants.pagesToLoad

		range.forEach { index in
			let limit = Constants.limit // i.e., 25 GIFs
			let offset = index * limit
			NetworkingAPI.getTrendingGifs(offset: offset, limit: limit) { [weak self] gifs in
				guard let self = self else { return }
				self.results[index] = gifs
				self.receivedNewGifObjects?(self.flattenedGifsResults)
			}
		}
	}

	/// This will fetch the next page's worth of GIFs.
	func addNextGifObjects() {
		let index = nextIndex()
		let offset = Constants.limit * index
		NetworkingAPI.getTrendingGifs(offset: offset) { [weak self] gifs in
			guard let self = self else { return }
			self.results[index] = gifs
			self.receivedNewGifObjects?(self.flattenedGifsResults)
		}
	}

	// gives all GIF objects from results as a flattened array (they're ordered
	// by the page number they were requested from). Sorted by key i.e. offset
	// example: [2: [GIF1, GIF2], 1: [GIF3], 3: [GIF4, GIF5]]
	// result = [GIF3, GIF1, GIF2, GIF4, GIF5]
	var flattenedGifsResults: [GifObject] {
		return results.sorted { $0.key < $1.key }.flatMap { $0.value }
	}

	private func nextIndex() -> Int {
		guard let last = results.keys.sorted().last else { return 0 }
		return last + 1
	}
}
