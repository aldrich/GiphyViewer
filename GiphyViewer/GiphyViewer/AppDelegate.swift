//
//  AppDelegate.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		window = UIWindow(frame: UIScreen.main.bounds)
		if let window = window {
			let viewModel = ViewModel()
			let viewController = ViewController(viewModel: viewModel)
			window.rootViewController = UINavigationController(rootViewController: viewController)
			window.makeKeyAndVisible()
		}
		return true
	}
}

