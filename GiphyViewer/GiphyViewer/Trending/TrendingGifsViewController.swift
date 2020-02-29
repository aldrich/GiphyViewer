//
//  ViewController.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import SnapKit

class TrendingGifsViewController: UIViewController {
	
	private var cellSizes = [[CGSize]]()
	
	private let viewModel: TrendingGifsViewModel
	private let collectionViewProvider = CollectionViewProvider()	
	
	let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collVw = UICollectionView(frame: .zero,
									  collectionViewLayout: layout)
		return collVw
	}()
	
	init(viewModel: TrendingGifsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		self.title = "Trending"
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
		
		collectionView.backgroundColor = .black
		setupCollectionView()
		prepareCellSizes()
		
		collectionView.reloadData()
		
		// try the appending.
		viewModel.newItems = { [weak self] gifs in
			self?.collectionViewProvider.items = [gifs] // give first section
			self?.collectionViewProvider.supplementaryItems = ["i"]
			self?.prepareCellSizes()
			self?.collectionView.reloadData()
		}
	}
	
	private func setupCollectionView() {
		collectionView.dataSource = collectionViewProvider
		collectionView.delegate = self
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

extension TrendingGifsViewController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let gifObject = self.collectionViewProvider.items[indexPath.section][indexPath.row]
		viewModel.selectedGif?(gifObject)
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		
		guard elementKind == UICollectionView.elementKindSectionFooter else { return }
		
		let elementCount = collectionViewProvider.items
			.flatMap { $0 }
			.count
		
		viewModel.getGifs(offset: elementCount) { [weak self] gifs in
			self?.collectionViewProvider.items.append(gifs)
			self?.collectionViewProvider.supplementaryItems.append("ii")
			self?.prepareCellSizes() // recomputing old objects
			self?.collectionView.reloadData()
		}
	}
}

extension TrendingGifsViewController: LayoutDelegate {
	func cellSize(indexPath: IndexPath) -> CGSize {
		return cellSizes[indexPath.section][indexPath.row]
	}
	
	func headerHeight(indexPath: IndexPath) -> CGFloat {
		return 0
	}
	
	func footerHeight(indexPath: IndexPath) -> CGFloat {
		let sectionsCount = collectionViewProvider.supplementaryItems.count
		return (indexPath.section == sectionsCount - 1) ? 24 : 0
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
