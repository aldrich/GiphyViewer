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
	
	init(viewModel: TrendingGifsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		self.title = "Trending"
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
			setGridLayout(columns: 3)
        } else {
            setGridLayout(columns: 2)
        }
    }

	func setGridLayout(columns: Int) {
		let layout = GridLayout()
		layout.columnsCount = columns
		collectionView.collectionViewLayout = layout
		layout.delegate = self
		layout.cellsPadding = ItemsPadding(horizontal: 8, vertical: 8)
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
			make.edges.equalToSuperview()
		}
		
		collectionView.backgroundColor = .black
		setupCollectionView()
		prepareCellSizes()
		collectionView.reloadData()

		// try the appending.
		viewModel.newItems = { [weak self] gifs in
			guard let self = self else { return }
			self.updateWithNewItems(gifs)
		}
	}

	private func updateWithNewItems(_ items: [GifObject]) {
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

	// will trigger a next page fetch from the API
	func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {

		guard elementKind == UICollectionView.elementKindSectionFooter else { return }

		// no fetching until you reached end of a populated list
		guard let gifs = collectionViewProvider.items.first, gifs.count > 0 else { return }

		let elementCount = collectionViewProvider.items
			.flatMap { $0 }
			.count

		viewModel.getGifObjects(offset: elementCount) { [weak self] gifs in
			guard let self = self,
				let existingItems = self.collectionViewProvider.items.first else { return }

			self.updateWithNewItems(existingItems + gifs)
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
		return (indexPath.section == sectionsCount - 1) ? CGFloat.leastNonzeroMagnitude : 0
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
