//
//  ViewModel.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

class TrendingGifsViewModel {

	var selectedGif: ((GifObject) -> Void)?

	var newItems: (([GifObject]) -> Void)?

	var results = [Int: [GifObject]]()

	init() {
		// initial load pages 0 to 24 (25 items each)
		(0...24).forEach { index in
			NetworkingAPI.getTrendingGifs(offset: index * 25, limit: 25) { [weak self] gifs, offset in
				guard let self = self else { return }
				self.results[index] = gifs
				let res = self.flattenedGifsResults
				self.newItems?(res)
			}
		}
	}

	func getGifs(offset: Int = 0, complete: @escaping (([GifObject]) -> Void)) {
		NetworkingAPI.getTrendingGifs(offset: offset) { gifs, offset in
			complete(gifs)
		}
	}

	private var flattenedGifsResults: [GifObject] {
		return results.sorted { $0.key < $1.key }.flatMap { $0.value }
	}
}
