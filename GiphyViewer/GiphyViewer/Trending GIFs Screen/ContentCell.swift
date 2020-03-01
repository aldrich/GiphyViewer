//
//  Views.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import Gifu

class ContentCell: UICollectionViewCell {

	func getRandomColor() -> UIColor {
		return UIColor.random().withAlphaComponent(0.2)
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		// free up resources (Gifu framework)
		imageView.prepareForReuse()
		imageView.image = UIImage(color: getRandomColor())!
	}

	// When scrolling quickly, a collection view cell can be reused many times
	// and asked to load different GIF objects. Sometimes the GIFs finish
	// loading after it's been reused for a different part of the collection view
	// where another GIF should have been displayed. Throttling would minimize
	// this issue by ensuring that only the GIF the cell needs to display at this
	// time should be loaded. But avoid giving too large a delay otherwise the
	// GIFs would take that much time to start loading.
	let throttler = Throttler(minimumDelay: 0.75)

	let imageView = GIFImageView()

	func populate(with item: GifObject) {
		backgroundColor = getRandomColor()
		imageView.image = UIImage(color: getRandomColor())!
		guard let url = item.fixedWidthDownsampledImage?.imageURL else {
			return
		}
		throttler.throttle { [weak self] in
			self?.imageView.animate(withGIFURL: url)
		}
		self.accessibilityLabel = item.title
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		contentView.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class FooterView: UICollectionReusableView {

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
