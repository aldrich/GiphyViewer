//
//  GifDetailViewController.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyGif
import Photos

class GifDetailViewController: UIViewController {

	private let viewModel: GifDetailViewModel

	let infoLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12)
		label.numberOfLines = 0
		label.textColor = .white
		label.textAlignment = .center
		return label
	}()

	let imageView = UIImageView()

	init(viewModel: GifDetailViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		title = viewModel.gif.title

		imageView.backgroundColor = UIColor.darkGray
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

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

		var dateStr = viewModel.gif.importDatetime
		if let date = dateFormatter.date(from: viewModel.gif.importDatetime) {
			dateFormatter.dateFormat = "MMMM dd yyyy, h:mm a"
			dateStr = dateFormatter.string(from: date)
		}

		let username = viewModel.gif.username
		if username.isEmpty {
			infoLabel.text = String(format: "Uploaded on %@", dateStr)
		} else {
			infoLabel.text = String(format: "Uploaded %@ by %@", dateStr, username)
		}

		if let size = viewModel.gif.sizeFullScreenImage {
			// use image size to fix the aspect ratio
			imageView.snp.makeConstraints { make in
				make.center.equalToSuperview()
				make.top.leading.greaterThanOrEqualTo(10)
				make.bottom.trailing.lessThanOrEqualTo(10)
				make.width.equalTo(imageView.snp.height)
					.multipliedBy(size.width / size.height)
				make.width.height.equalToSuperview().priority(.high)
				make.height.lessThanOrEqualTo(size.height)
			}
		} else {
			imageView.snp.makeConstraints { make in
				make.edges.equalToSuperview()
			}
		}
		loadGif()
		setSaveButtonItem()
    }

	private func loadGif() {
		if let url = viewModel.gif.urlFullScreenImage {
			imageView.setGifFromURL(url)
		} else {
			infoLabel.text = "Unable to load image"
		}
	}

	private func setSaveButtonItem() {
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
		target: self,
		action: #selector(save))
	}

	@objc func save() {
		NetworkingAPI.download(gif: viewModel.gif) { [weak self] data in
			guard let self = self else { return }
			if let data = data {

				PHPhotoLibrary.shared().performChanges({
					let request = PHAssetCreationRequest.forAsset()
					request.addResource(with: .photo, data: data, options: nil)
				}) { (success, error) in
					DispatchQueue.main.async {
						if let error = error {
							print(error.localizedDescription)
						} else {
							let alert = UIAlertController(title: "Success",
														  message: "Saved to Gallery",
														  preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
							self.present(alert, animated: true) {}
						}
					}
				}
			}
		}
	}
}
