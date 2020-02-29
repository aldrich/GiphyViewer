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

	private let networking = NetworkingApi()

	var newItems: (([GifObject]) -> Void)?

	init() {
		getGifs(offset: 0) { [weak self] gifs in
			self?.newItems?(gifs)
		}
	}

	func getGifs(offset: Int = 0, complete: @escaping (([GifObject]) -> Void)) {
		self.networking.getTrendingGifs(offset: offset) { gifs in
			complete(gifs)
		}
	}
}
