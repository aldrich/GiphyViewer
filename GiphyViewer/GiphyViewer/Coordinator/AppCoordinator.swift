//
//  AppCoordinator.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinator: BaseCoordinator {

	private var window = UIWindow(frame: UIScreen.main.bounds)

	override init() {}

	override func start() {
		self.window.makeKeyAndVisible()
		showGifList()
	}

	private func showGifList() {
		self.removeChildCoordinators()

		let viewModel = TrendingGifsViewModel(networking: GiphyAPIClient())
		let coordinator = TrendingGifsListCoordinator(viewModel: viewModel)

		coordinator.navigationController = UINavigationController()

		self.start(coordinator: coordinator)

		ViewControllerUtils.setRootViewController(
			window: self.window,
			viewController: coordinator.navigationController,
			withAnimation: true)
	}

}
