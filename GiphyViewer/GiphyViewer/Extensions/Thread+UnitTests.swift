//
//  Thread+UnitTests.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 3/1/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

extension Thread {
	/// Allows runtime detection of unit tests
	/// from: https://medium.com/@theinkedengineer/check-if-app-is-running-unit-tests-the-swift-way-b51fbfd07989
	var isRunningXCTest: Bool {
		for key in self.threadDictionary.allKeys {
			guard let keyAsString = key as? String else {
				continue
			}
			if keyAsString.split(separator: ".").contains("xctest") {
				return true
			}
		}
		return false
	}
}
