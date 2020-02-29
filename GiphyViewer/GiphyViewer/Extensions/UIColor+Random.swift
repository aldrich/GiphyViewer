//
//  UIColor+Random.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

extension UIColor {
	static func random() -> UIColor {
		return UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0)
	}
}
