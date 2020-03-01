//
//  GifDetailViewController.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import SnapKit
import Gifu
import Photos

class GifDetailViewController: UIViewController {

	enum Constants {
		// typical form returned by API
		static let inputDateFormat = "yyyy-MM-dd hh:mm:ss"

		static let outputDateFormat = "MMMM dd yyyy, h:mm a"

		static let failedToLoadMessage = "Unable to load image"
	}

	private let viewModel: GifDetailViewModel

	private var gifObject: GifObject {
		return viewModel.gif
	}

	let infoLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12)
		label.numberOfLines = 0
		label.textColor = .white
		label.textAlignment = .center
		return label
	}()

	let imageView = GIFImageView()

	init(viewModel: GifDetailViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		title = viewModel.gif.title
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .black

		view.addSubview(imageView)
		view.addSubview(infoLabel)

		infoLabel.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
			make.bottom.equalToSuperview().offset(-12)
		}

		imageView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.top.leading.greaterThanOrEqualTo(10)
			make.bottom.trailing.lessThanOrEqualTo(10)
			make.width.height.equalToSuperview().priority(.high)

			// use image's size to fix the aspect ratio
			if let size = gifObject.fullScreenGifImage?.dimensions {
				let ratio = size.width / size.height
				make.width.equalTo(imageView.snp.height).multipliedBy(ratio)
				make.height.lessThanOrEqualTo(size.height)
			}
		}

		loadGif()
		setSaveButton()
		setInfoPanel()
    }

	private func setInfoPanel() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = Constants.inputDateFormat
		var dateStr = gifObject.importDatetime
		if let date = dateFormatter.date(from: dateStr) {
			dateFormatter.dateFormat = Constants.outputDateFormat
			dateStr = dateFormatter.string(from: date)
		}
		let username = gifObject.username
		if username.isEmpty {
			infoLabel.text = String(format: "Uploaded on %@", dateStr)
		} else {
			infoLabel.text = String(format: "Uploaded %@ by %@", dateStr, username)
		}
	}

	private func loadGif() {

		// add a low-cost still image to display while loading full gif
		if let url = gifObject.fixedWidthStillImage?.imageURL {
			getData(from: url) { data, response, error in
				DispatchQueue.main.async { [weak self] in
					guard let self = self, let data = data else { return }
					self.imageView.image = UIImage(data: data)
					let spinner = UIActivityIndicatorView(style: .large)
					spinner.startAnimating()
					self.imageView.addSubview(spinner)
					spinner.snp.makeConstraints { (make) in
						make.center.equalToSuperview()
					}
				}
			}
		}

		// also load full gif simultaneously and show it if its ready
		if let url = gifObject.fullScreenGifImage?.imageURL {
			self.imageView.animate(withGIFURL: url, loopCount: 0) {
				DispatchQueue.main.async { [weak self] in
					self?.imageView.image = nil
					self?.imageView.subviews.forEach {
						$0.removeFromSuperview()
					}
				}
			}
		}
	}

	func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
		URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
	}

	func downloadImage(from url: URL) {
		print("Download Started")
		getData(from: url) { data, response, error in
			guard let data = data, error == nil else { return }
			print(response?.suggestedFilename ?? url.lastPathComponent)
			print("Download Finished")
			DispatchQueue.main.async() {
				self.imageView.image = UIImage(data: data)
			}
		}
	}

	private func setSaveButton(isBusy: Bool = false) {
		guard !isBusy else {
			let spinner = UIActivityIndicatorView(style: .medium)
			navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
			spinner.startAnimating()
			return
		}
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
															target: self,
															action: #selector(save))
	}

	@objc func save() {
		setSaveButton(isBusy: true)

		NetworkingAPI.download(gif: viewModel.gif) { [weak self] data in
			guard let self = self, let data = data else { return }
			PHPhotoLibrary.shared().performChanges({
				let request = PHAssetCreationRequest.forAsset()
				request.addResource(with: .photo, data: data, options: nil)
			}) { success, error in
				DispatchQueue.main.async { [weak self] in
					if let error = error {
						print(error.localizedDescription)
					} else {
						let alert = UIAlertController(title: "Success",
													  message: "Saved GIF to Gallery!",
													  preferredStyle: .alert)
						alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
						self?.present(alert, animated: true) {}
					}
					self?.setSaveButton()
				}
			}
		}
	}
}
