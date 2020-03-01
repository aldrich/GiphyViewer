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
		static let failedToLoadMessage = "Unable to load image"
	}

	private let viewModel: GifDetailViewModel

	let imageView = GIFImageView()

	let infoLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12)
		label.numberOfLines = 0
		label.textColor = .white
		label.textAlignment = .center
		return label
	}()

	init(viewModel: GifDetailViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		title = gifObject.title
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

		loadGifImage()
		setSaveButton()

		infoLabel.text = viewModel.getUploadInfo()
    }

	private func loadGifImage() {
		// add a low-cost still image to display while loading full gif
		if let url = stillImageURL {
			viewModel.fetchData(from: url) { [weak self] data in
				guard let self = self, let data = data else { return }
				self.imageView.image = UIImage(data: data)
				self.imageView.showSpinner()
			}
		}
		// simultaneously load full gif (which appears later) and show it if
		// it's ready, removing the static placeholder image.
		if let url = fullScreenGifImageURL {
			imageView.animate(withGIFURL: url) { // on GIF load completion,
				DispatchQueue.main.async { [weak self] in
					self?.imageView.showSpinner(false)
					self?.imageView.image = nil
				}
			}
		}
	}

	enum RightSideButtonMode {
		case busy
		case saveButton
	}

	/// Show the save button on the right side of the navigation button, or a
	/// busy spinner in its place (if isBusy is true)
	private func setSaveButton(mode: RightSideButtonMode = .saveButton) {
		guard mode == .saveButton else {
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
		setSaveButton(mode: .busy)
		// must have original (full-sized) GIF image with url to proceed
		guard let originalImage = gifObject.originalImage,
			let hqImageURL = originalImage.imageURL else {
				print("original GIF image not available.")
				return
		}

		viewModel.downloadAndSaveToPhotoGallery(url: hqImageURL) { [weak self] error in
			self?.showPostSaveGIFAlert(error: error)
			self?.setSaveButton()
		}
	}

	private func showPostSaveGIFAlert(error: Error? = nil) {
		var alert: UIAlertController!
		if let error = error {
			alert = UIAlertController(title: "Failure",
									  message: error.localizedDescription,
									  preferredStyle: .alert)
		} else {
			alert = UIAlertController(title: "Success",
									  message: "Saved GIF to Gallery!",
									  preferredStyle: .alert)
		}
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true) {}
	}
}

extension GifDetailViewController {
	private var gifObject: GifObject {
		return viewModel.gif
	}

	private var stillImageURL: URL? {
		return gifObject.fixedWidthStillImage?.imageURL
	}

	private var fullScreenGifImageURL: URL? {
		return gifObject.fullScreenGifImage?.imageURL
	}
}

extension UIImageView {

	// Adds a spinner on the main gif view while the actual gif is still loading
	func showSpinner(_ show: Bool = true) {
		guard show else {
			self.subviews.forEach { $0.removeFromSuperview() }
			return
		}
		let spinner = UIActivityIndicatorView(style: .large)
		spinner.startAnimating()
		self.addSubview(spinner)
		spinner.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
		}
	}
}
