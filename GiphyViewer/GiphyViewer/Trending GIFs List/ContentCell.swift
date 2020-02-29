//
//  Views.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import SwiftyGif

class ContentCell: UICollectionViewCell {

	override func prepareForReuse() {
		super.prepareForReuse()
		label.text = nil
	}

	let imageView = UIImageView()

	let label: UILabel = {
		let ret = UILabel()
		ret.textColor = .white
		ret.backgroundColor = UIColor(white: 0, alpha: 0.6)
		ret.numberOfLines = 0
		ret.font = .systemFont(ofSize: 12)
		ret.textAlignment = .center
		return ret
	}()

	func populate(with item: GifObject, index: Int) {
		backgroundColor = UIColor.random()
			.withAlphaComponent(0.3)
		label.text = item.title
		if let url = item.urlFixedWidth {
			self.imageView.setGifFromURL(url)
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
