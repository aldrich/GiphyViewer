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

class GifDetailViewController: UIViewController {

	private let viewModel: GifDetailViewModel

	let infoLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16)
		label.numberOfLines = 0
		return label
	}()


	let imageView = UIImageView()

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
			make.bottom.trailing.equalToSuperview().offset(-10)
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

		if let url = viewModel.gif.urlFullScreenImage {
			imageView.setGifFromURL(url)
		} else {
			infoLabel.text = "Unable to load image"
		}
    }
}
