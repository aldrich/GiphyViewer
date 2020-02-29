//
//  TrendingGifsListCoordinator.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import UIKit

class TrendingGifsListCoordinator: BaseCoordinator {

    private let viewModel: TrendingGifsViewModel

    init(viewModel: TrendingGifsViewModel) {
		self.viewModel = viewModel
		super.init()

		viewModel.selectedGif = { [weak self] gifObject in
			self?.showDetail(gif: gifObject)
		}
	}

    override func start() {
		let viewController = TrendingGifsViewController(viewModel: viewModel)
        // self.navigationController.isNavigationBarHidden = true
        self.navigationController.viewControllers = [viewController]
    }

	private func showDetail(gif: GifObject) {
		let viewModel = GifDetailViewModel(gif: gif)
		let viewController = GifDetailViewController(viewModel: viewModel)
		self.navigationController.pushViewController(viewController, animated: true)
	}
}
