//
//  ViewController.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
	
	
	private var cellSizes = [[CGSize]]()
	
	private let viewModel: ViewModel
	private let collectionViewProvider = CollectionViewProvider()	
	
	let collectionView: UICollectionView = {
		
		let collVw = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		
		// configure collection view appearance here.
		
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
		
		view.addSubview(collectionView)
		collectionView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		view.backgroundColor = .green
		collectionView.backgroundColor = .cyan
		
		setupCollectionView()
		prepareCellSizes()
		
		collectionView.reloadData()
	}
	
	private func setupCollectionView() {
		collectionView.dataSource = collectionViewProvider
		
		let firstSectionItems = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
								 "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen",
								 "eighteen", "nineteen", "twenty"]
		
		let secondSectionItems = ["activity", "appstore", "calculator", "camera", "contacts", "clock", "facetime",
								  "health", "mail", "messages", "music", "notes", "phone", "photos", "podcasts",
								  "reminders", "safari", "settings", "shortcuts", "testflight", "wallet", "watch",
								  "weather"]
		
		
		collectionViewProvider.items = [firstSectionItems, secondSectionItems]
		collectionViewProvider.supplementaryItems = ["numbers", "apps"]
		
		let layout = GridLayout()
		collectionView.collectionViewLayout = layout
		layout.delegate = self
		
	}
	
	private func prepareCellSizes() {
		let range = 50...150
		cellSizes.removeAll()
		collectionViewProvider.items.forEach { items in
			let sizes = items.map { item -> CGSize in
				let height = CGFloat(Int.random(in: range))
				return CGSize(width: 0.1, height: height)
			}
			cellSizes.append(sizes)
		}
	}
}

extension ViewController: LayoutDelegate {
	func cellSize(indexPath: IndexPath) -> CGSize {
		return cellSizes[indexPath.section][indexPath.row]
	}
	
	func headerHeight(indexPath: IndexPath) -> CGFloat {
        return 0
    }

    func footerHeight(indexPath: IndexPath) -> CGFloat {
        return 0
    }
}

class ContentCell: UICollectionViewCell {
	
	func populate(with item: String) {
		backgroundColor = UIColor.random()// .withAlphaComponent(0.5)
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
