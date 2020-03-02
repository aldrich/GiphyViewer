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
	}

	let imageView = GIFImageView()
	
	var gifObject: GifObject?
	
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
	
	func populate(with item: GifObject) {
		self.accessibilityLabel = item.title
		backgroundColor = getRandomColor()
		imageView.image = UIImage(color: getRandomColor())!
		self.gifObject = item
	}
	
	func startAnimatingGif() {
		self.loadGif()
	}
	
	// look for cached data, and if found, return it instead of
	private func loadGif() {
		if let data = gifObject?.cachedData(forUnit: .small) {
			imageView.animate(withGIFData: data)
		} else {
			if let url = gifObject?.fixedWidthDownsampledImage?.imageURL {
				imageView.animate(withGIFURL: url)
			}
		}
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
