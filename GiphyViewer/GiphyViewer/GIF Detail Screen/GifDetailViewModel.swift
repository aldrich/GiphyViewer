//
//  GifDetailViewModel.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import Photos

class GifDetailViewModel {

	enum Constants {
		// typical form returned by API
		static let inputDateFormat = "yyyy-MM-dd HH:mm:ss"

		static let outputDateFormat = "MMMM dd yyyy, h:mm a"
	}

	let gif: GifObject
	let networking: GiphyAPIClient

	init(gif: GifObject, networking: GiphyAPIClient) {
		self.gif = gif
		self.networking = networking
	}

	/// Returns upload date/time and username of uploader (if present)
	func getUploadInfo() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = Constants.inputDateFormat
		var dateStr = gif.importDatetime
		if let date = dateFormatter.date(from: dateStr) {
			dateFormatter.dateFormat = Constants.outputDateFormat
			dateStr = dateFormatter.string(from: date)
		}
		let username = gif.username
		if username.isEmpty {
			return String(format: "Uploaded on %@", dateStr)
		} else {
			return String(format: "Uploaded %@ by %@", dateStr, username)
		}
	}

	func downloadAndSaveToPhotoGallery(url: URL, completion: @escaping (Error?) -> Void) {
		networking.download(url: url) { [weak self] data in
			guard let data = data else { print("empty download"); return }
			self?.saveDataAsGIFToPhotoGallery(data: data) { error in
				completion(error)
			}
		}
	}

	/// Saves Data object to Photos app as an image object, works for GIFs.
	/// Completion block is on the main thread.
	func saveDataAsGIFToPhotoGallery(data: Data,
									 completion: @escaping (Error?) -> Void) {
		
		guard PHPhotoLibrary.authorizationStatus() != .notDetermined else {
			PHPhotoLibrary.requestAuthorization { [weak self] (status) in
				self?.saveDataAsGIFToPhotoGallery(data: data, completion: completion)
			}
			return
		}
		PHPhotoLibrary.shared().performChanges({
			let request = PHAssetCreationRequest.forAsset()
			request.addResource(with: .photo, data: data, options: nil)
		}) { success, error in
			DispatchQueue.main.async {
				completion(error)
			}
		}
	}

	/// Downloads a Data object from the given URL. Returns to main block
	func fetchData(from url: URL, completion: @escaping (Data?) -> ()) {
		networking.download(url: url) { data in
			DispatchQueue.main.async {
				completion(data)
			}
		}
	}
}
