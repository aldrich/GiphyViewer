//
//  FooterView.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

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
			// as the footer view could momentarily be zero height, setting
			// lower-than-required priority to avoid constraint warnings for
			// the label.
			make.center.equalToSuperview().priority(.high)
			make.left.equalToSuperview().offset(10).priority(.high)
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
