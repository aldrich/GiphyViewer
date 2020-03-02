//
//  Cache.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 3/2/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import PINCache

enum CacheUnit {
	case small
	case still
	case large // or original
}

extension Date {
	static func secondsAgo(_ seconds: Int) -> Date? {
		let calendar = Calendar.current
		return calendar.date(byAdding: .second,
							 value: -seconds,
							 to: Date())
	}
}

class GIFCache {
	
	static let shared = GIFCache()
	
	enum Constants {
		// cached items not used before this time will get
		// erased during startup
		static let maxAgeInSeconds = 60 * 60 // one hour
	}
	
	let cache: PINCache = {
		let sharedCache = PINCache.shared()
		if let recentPast = Date.secondsAgo(Constants.maxAgeInSeconds) {
			sharedCache.trim(to: recentPast)
		}
		return sharedCache
	}()
	
	func hasObjectForKey(_ key: String) -> Bool {
		return cache.containsObject(forKey: key)
	}
	
	func setObject(data: Data, forKey key: String) {
		cache.setObject(NSData(data: data), forKey: key)
	}
	
	func object(forKey key: String) -> Data? {
		return cache.object(forKey: key) as? Data
	}
}

extension GifObject {
	
	func isCached(forUnit unit: CacheUnit,
				  in cache: GIFCache = .shared) -> Bool {
		let key = cacheKey(forUnit: unit)
		return cache.hasObjectForKey(key)
	}
	
	func cacheData(_ data: Data, forUnit unit: CacheUnit,
				   in cache: GIFCache = .shared) {
		let key = cacheKey(forUnit: unit)
		cache.setObject(data: data, forKey: key)
	}
	
	func cachedData(forUnit unit: CacheUnit, in cache: GIFCache = .shared) -> Data? {
		let key = cacheKey(forUnit: unit)
		return cache.object(forKey: key)
	}
	
	func cacheKey(forUnit unit: CacheUnit) -> String {
		switch unit {
		case .small:
			return "small-\(id)"
		case .still:
			return "still-\(id)"
		case .large:
			return "large-\(id)"
		}
	}
}
