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
		imageView.clear()
		label.text = nil
	}

	let label: UILabel = {
		let ret = UILabel()
		ret.textColor = .white
		ret.numberOfLines = 0
		ret.font = .systemFont(ofSize: 12)
		ret.textAlignment = .center
		return ret
	}()

	let imageView: UIImageView = {
		let ret = UIImageView()
		return ret
	}()

	func populate(with item: GifObject) {
		backgroundColor = UIColor.random()
			.withAlphaComponent(0.5)
		label.text = "" // item.title
		if let url = item.urlFixedWidth {
			imageView.setGifFromURL(url, levelOfIntegrity: .lowForTooManyGifs)
		} else {
			print()
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
			make.centerX.equalToSuperview()
			make.left.equalToSuperview().offset(10)
			make.bottom.equalToSuperview().offset(-10)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class HeaderView: UICollectionReusableView {

	let label: UILabel = {
		let ret = UILabel()
		ret.textColor = .white
		ret.numberOfLines = 0
		ret.font = .systemFont(ofSize: 12)
		ret.textAlignment = .center
		return ret
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addSubview(label)
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.left.equalToSuperview().offset(10)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func populate(with item: String) {
		label.text = item

		backgroundColor = UIColor.random().withAlphaComponent(0.5)
	}
}

class FooterView: UICollectionReusableView {

	let label: UILabel = {
		let ret = UILabel()
		ret.textColor = .white
		ret.numberOfLines = 0
		ret.font = .systemFont(ofSize: 12)
		ret.textAlignment = .center
		return ret
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addSubview(label)
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.left.equalToSuperview().offset(10)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func populate(with item: String) {
		label.text = item
		backgroundColor = UIColor.random().withAlphaComponent(0.5)
	}
}

public extension UIImage {
	convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
}