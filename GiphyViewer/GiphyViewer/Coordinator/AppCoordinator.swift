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

	override init() {
		// inject any dependencies here.
	}

	override func start() {
		self.window.makeKeyAndVisible()
		showGifList()
	}

	private func showGifList() {
		self.removeChildCoordinators()

		let viewModel = TrendingGifsViewModel() // use dependency injection
		let coordinator = TrendingGifsListCoordinator(viewModel: viewModel)
			// AppDelegate.container.resolve(DrawerMenuCoordinator.self)!

		coordinator.navigationController = UINavigationController() // BaseNavigationController()


		self.start(coordinator: coordinator)

		ViewControllerUtils.setRootViewController(
			window: self.window,
			viewController: coordinator.navigationController,
			withAnimation: true)
	}

}
