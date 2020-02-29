//
//  ViewController.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyGif

class TrendingGifsViewController: UIViewController {
	
	private var cellSizes = [[CGSize]]()
	
	private let viewModel: ViewModel
	private let collectionViewProvider = CollectionViewProvider()	
	
	let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collVw = UICollectionView(frame: .zero,
									  collectionViewLayout: layout)
		return collVw
	}()
	
	init(viewModel: ViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView.register(ContentCell.self,
								forCellWithReuseIdentifier: "ContentCell")
		collectionView.register(HeaderView.self,
								forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
								withReuseIdentifier: "HeaderViewIdentifier")
		collectionView.register(FooterView.self,
								forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
								withReuseIdentifier: "FooterViewIdentifier")

		view.addSubview(collectionView)
		collectionView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		collectionView.backgroundColor = .white
		
		setupCollectionView()
		prepareCellSizes()
		
		collectionView.reloadData()

		viewModel.newItems = { [weak self] gifs in
			self?.collectionViewProvider.items = [gifs] // give first section
			self?.collectionViewProvider.supplementaryItems = ["i"]
			self?.prepareCellSizes()
			self?.collectionView.reloadData()
		}
	}
	
	private func setupCollectionView() {
		collectionView.dataSource = collectionViewProvider
		collectionViewProvider.items = []
		collectionViewProvider.supplementaryItems = []
		let layout = GridLayout()
		collectionView.collectionViewLayout = layout
		layout.delegate = self
		layout.cellsPadding = ItemsPadding(horizontal: 8, vertical: 8)
	}
	
	private func prepareCellSizes() {
		cellSizes.removeAll()
		collectionViewProvider.items.forEach { items in
			let sizes = items.map { item -> CGSize in
				if let image = item.images["fixed_width_downsampled"],
					let heightStr = image.height,
					let height = Float(heightStr) {
					return CGSize(width: 200, height: CGFloat(height))
				}
				return CGSize(width: 200, height: 0.1)
			}
			cellSizes.append(sizes)
		}
	}
}

extension TrendingGifsViewController: LayoutDelegate {
	func cellSize(indexPath: IndexPath) -> CGSize {
		return cellSizes[indexPath.section][indexPath.row]
	}
	
	func headerHeight(indexPath: IndexPath) -> CGFloat {
        return 12
    }

    func footerHeight(indexPath: IndexPath) -> CGFloat {
        return 12
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0)
    }
}

extension GifObject {

	var urlFixedWidth: URL? {
		if let url = fixedWidthDownsampledImage?.url {
			return URL(string: url)
		}
		return nil
	}

	var heightFixedWidth: CGFloat? {
		if let heightStr = fixedWidthDownsampledImage?.height,
			let floatValue = NumberFormatter().number(from: heightStr)?.floatValue {
			return CGFloat(floatValue)
		}
		return nil
	}

	var fixedWidthDownsampledImage: ImageObject? {
		return images["fixed_width_downsampled"]
	}
}
