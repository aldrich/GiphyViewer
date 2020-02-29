//
//  GifListCoordinator.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import UIKit

class GifListCoordinator: BaseCoordinator {

    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    override func start() {
		let viewController = TrendingGifsViewController(viewModel: viewModel)

        self.navigationController.isNavigationBarHidden = true
        self.navigationController.viewControllers = [viewController]
    }
}
