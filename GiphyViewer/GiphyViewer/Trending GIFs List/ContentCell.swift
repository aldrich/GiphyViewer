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

	override func prepareForReuse() {
		super.prepareForReuse()

		// only way to avoid another playing gif when a cell is reused
		let randomColorImage = UIImage(color: .random())!
		imageView.image = randomColorImage

		// free up resources (Gifu framework)
		imageView.prepareForReuse()
		label.text = nil
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

	let label: UILabel = {
		let ret = UILabel()
		ret.textColor = .white
		ret.backgroundColor = UIColor(white: 0, alpha: 0.4)
		ret.numberOfLines = 0
		ret.font = .systemFont(ofSize: 12)
		ret.textAlignment = .center
		return ret
	}()

	func populate(with item: GifObject) {
		backgroundColor = UIColor.random()
			.withAlphaComponent(0.3)
		label.text = item.title
		if let url = item.fixedWidthDownsampledImage?.imageURL {
			throttler.throttle { [weak self] in
				self?.imageView.animate(withGIFURL: url)
			}
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		contentView.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		contentView.addSubview(label)
		label.snp.makeConstraints { make in
			make.left.right.bottom.equalToSuperview()
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
