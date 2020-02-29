//
//  AppDelegate+Appearance.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {

	static func setNavigationBarButtonItemAppearance() {
		let backImage = #imageLiteral(resourceName: "back-button-item")
			.withRenderingMode(.alwaysTemplate)
		UINavigationBar.appearance().backIndicatorImage = backImage
		UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
	}
}
