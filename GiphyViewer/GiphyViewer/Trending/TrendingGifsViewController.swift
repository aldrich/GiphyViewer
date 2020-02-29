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

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            // Landscape
			setGridLayout(columns: 3)
        } else {
			// Portrait
            setGridLayout(columns: 2)
        }
    }

	func setGridLayout(columns: Int) {
		let layout = GridLayout()
		layout.columnsCount = columns
		collectionView.collectionViewLayout = layout
		layout.delegate = self
		layout.cellsPadding = ItemsPadding(horizontal: 8, vertical: 8)
		collectionView.reloadData()
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
			guard let self = self else { return }

			// using collection diffing (Swift 5.1) to optimize reloads
			if let storedItems = self.gifItems {
				let diff = gifs.difference(from: storedItems)
				let toRemove = diff.removals.compactMap { change -> IndexPath? in
					switch change {
					case let .remove(offset, _, _): return IndexPath(row: offset, section: 0)
					default: return nil
					}
				}
				let toInsert = diff.insertions.compactMap { change -> IndexPath? in
					switch change {
					case let .insert(offset, _, _): return IndexPath(row: offset, section: 0)
					default: return nil
					}
				}

				self.collectionViewProvider.items = [gifs]
				self.collectionViewProvider.supplementaryItems = [""]
				self.prepareCellSizes()

				self.collectionView.performBatchUpdates({
					self.collectionView.deleteItems(at: toRemove)
					self.collectionView.insertItems(at: toInsert)
				}, completion: { (success) in
					print("success: \(success)")
				})
			} else {
				// initially empty
				self.collectionViewProvider.items = [[]] // give first section
				self.collectionViewProvider.supplementaryItems = [""]
				self.prepareCellSizes()
				self.collectionView.reloadData()
			}
		}
	}

	private var gifItems: [GifObject]? {
		return  self.collectionViewProvider.items.first
	}

	private func setupCollectionView() {
		collectionView.dataSource = collectionViewProvider
		collectionView.delegate = self
		collectionViewProvider.items = []
		collectionViewProvider.supplementaryItems = []

		setGridLayout(columns: 2)
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
			guard let self = self else { return }
			guard let firstSection = self.collectionViewProvider.items.first else { return }
			self.collectionViewProvider.items = [firstSection + gifs]
			self.prepareCellSizes() // recomputing old objects
			self.collectionView.reloadData()
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

	var fullScreenImage: ImageObject? {
		return images["original"]
	}

	var urlFullScreenImage: URL? {
		if let url = fullScreenImage?.url {
			return URL(string: url)
		}
		return nil
	}

	var sizeFullScreenImage: CGSize? {
		if let widthStr = fullScreenImage?.width,
			let heightStr = fullScreenImage?.height,
			let width = Int(widthStr),
			let height = Int(heightStr) {
			return CGSize(width: width, height: height)
		}
		return nil
	}
}
