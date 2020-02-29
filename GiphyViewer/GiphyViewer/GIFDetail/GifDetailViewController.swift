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

	let imageView = UIImageView()

	init(viewModel: GifDetailViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .black

		view.addSubview(imageView)

		if let size = viewModel.gif.sizeFullScreenImage {
			imageView.snp.makeConstraints { make in
				make.center.equalToSuperview()
				make.top.leading.greaterThanOrEqualTo(10)
				make.bottom.trailing.lessThanOrEqualTo(10)
				make.width.equalTo(imageView.snp.height).multipliedBy(size.width / size.height)
				make.width.height.equalToSuperview().priority(.high)
				make.height.lessThanOrEqualTo(size.height)
			}
		}

		if let url = viewModel.gif.urlFullScreenImage {
			imageView.setGifFromURL(url)
		}
    }
}
