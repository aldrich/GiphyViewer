//
//  TrendingGifsCollectionViewProvider.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

class TrendingGifsCollectionViewProvider: NSObject, UICollectionViewDataSource {
	
	var items = [[GifObject]]()
	var supplementaryItems = [String]()

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return supplementaryItems.count
	}
	
	func collectionView(_ collectionView: UICollectionView,
						numberOfItemsInSection section: Int) -> Int {
		return items[section].count
	}
	
	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView
			.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath)
		
		if let cell = cell as? ContentCell {
			let item = items[indexPath.section][indexPath.row]
			cell.populate(with: item)
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView,
						viewForSupplementaryElementOfKind kind: String,
						at indexPath: IndexPath) -> UICollectionReusableView {

		return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
															   withReuseIdentifier: "FooterViewIdentifier",
															   for: indexPath)
	}
}
