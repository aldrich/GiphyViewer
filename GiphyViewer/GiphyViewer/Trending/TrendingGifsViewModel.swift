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
		networking.getTrendingGifs { [weak self] gifs in
			self?.newItems?(gifs)
		}
	}
}
