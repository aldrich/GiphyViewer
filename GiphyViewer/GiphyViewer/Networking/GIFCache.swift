//
//  Cache.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 3/2/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import PINCache

// The same images can be cached as different versions; small is for the
// width-fixed looping version used in the main list; still is the non-looping
// version with the same size as the original; and large is the best quality
// image as originally provided by the uploader.
enum CacheUnit {
	case small
	case still
	case large
}

extension Date {
	// Used in generate a Date object at a known time interval "ago" from the
	// current date, which will mainly be used to specify an oldest date to be
	// preserved in the cache when it gets trimmed.
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

	/// Returns true if the image data, for the given unit, is already found
	/// within the cache.
	func isCached(forUnit unit: CacheUnit,
				  in cache: GIFCache = .shared) -> Bool {
		let key = cacheKey(forUnit: unit)
		return cache.hasObjectForKey(key)
	}

	/// Caches the image data locally for the given unit.
	func cacheData(_ data: Data, forUnit unit: CacheUnit,
				   in cache: GIFCache = .shared) {
		let key = cacheKey(forUnit: unit)
		cache.setObject(data: data, forKey: key)
	}

	/// Returns the cached image object (Data) if found, for the correct unit,
	/// otherwise, will return nil.
	func cachedData(forUnit unit: CacheUnit, in cache: GIFCache = .shared) -> Data? {
		let key = cacheKey(forUnit: unit)
		return cache.object(forKey: key)
	}

	/// The cache key used for a GifObject based on the desired (size) unit.
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
