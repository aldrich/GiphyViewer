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

	private let collectionViewProvider = TrendingGifsCollectionViewProvider()

	private let collectionView = UICollectionView(frame: .zero,
												  collectionViewLayout: UICollectionViewFlowLayout())
	
	private let throttler = Throttler(minimumDelay: 0.5)
	
	init(viewModel: TrendingGifsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		self.title = "Trending"
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
		let numberOfColumns = getNumberOfColumns()
		setGridLayout(columns: numberOfColumns)
    }

	private func getNumberOfColumns() -> Int {
		guard UIDevice.current.orientation.isLandscape else {
			return 2
		}
		let size = UIScreen.main.bounds.size
		let landscapeWidth = max(size.width, size.height)
		let ret = ceil(landscapeWidth / 200.0)
		return Int(ret)
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
		collectionView.register(FooterView.self,
								forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
								withReuseIdentifier: "FooterViewIdentifier")

		view.addSubview(collectionView)
		collectionView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		collectionView.backgroundColor = .black
		setupCollectionView()
		prepareCellSizes()
		collectionView.reloadData()

		viewModel.receivedNewGifObjects = { [weak self] gifs in
			// self?.updateWithNewItems(gifs)
			self?.receivedGifs = gifs
			
			self?.throttler.throttle {
				self?.updateWithNewItems()
			}
		}

		viewModel.fetchInitialData()
	}
	
	private var receivedGifs: [GifObject]?

	private func updateWithNewItems() {
		
		guard let items = receivedGifs else { return }
		
		// using collection diffing to optimize reloads
		guard let currItems = self.collectionViewProvider.items.first else { return }

		let diff = items.difference(from: currItems)

		let toRemove = diff.removals.compactMap { change -> IndexPath? in
			guard case let .remove(offset, _, _) = change else {
				return nil
			}
			return IndexPath(row: offset, section: 0)
		}

		let toInsert = diff.insertions.compactMap { change -> IndexPath? in
			guard case let .insert(offset, _, _) = change else {
				return nil
			}
			return IndexPath(row: offset, section: 0)
		}

		collectionView.performBatchUpdates({ [weak self] in
			self?.collectionViewProvider.items = [items]
			self?.prepareCellSizes()
			self?.collectionView.deleteItems(at: toRemove)
			self?.collectionView.insertItems(at: toInsert)
		})
	}

	private func setupCollectionView() {
		collectionView.dataSource = collectionViewProvider
		collectionView.delegate = self
		collectionViewProvider.items = [[]]
		collectionViewProvider.supplementaryItems = [""]

		let numberOfColumns = getNumberOfColumns()
		setGridLayout(columns: numberOfColumns)
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
		guard elementKind == UICollectionView.elementKindSectionFooter,
			indexPath.row == 0, indexPath.section == 0 else { return }
		guard collectionView.contentOffset != .zero else { return }
		print("willDisplaySupplementaryView indexPath: \(indexPath)")
		viewModel.addNextGifObjects()
	}
	
//	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//		
//		guard let cell = cell as? ContentCell else { return }
//		cell.startAnimatingGif()
//	}
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
		return (indexPath.section == sectionsCount - 1) ? CGFloat.leastNonzeroMagnitude : 0
	}
}

extension GifObject {

	var fixedWidthDownsampledImage: ImageObject? {
		return images["fixed_width_downsampled"]
	}

	var fullScreenGifImage: ImageObject? {
		return images["original"]
	}

	var fixedWidthStillImage: ImageObject? {
		return images["fixed_width_still"]
	}

	var originalImage: ImageObject? {
		return images["original"]
	}
}

extension ImageObject {

	var imageURL: URL? {
		if let url = self.url {
			return URL(string: url)
		}
		return nil
	}

	var dimensions: CGSize? {
		if let widthStr = width,
			let heightStr = height,
			let width = Int(widthStr),
			let height = Int(heightStr),
			width > 0, height > 0 {
			return CGSize(width: width, height: height)
		}
		return nil
	}
}
