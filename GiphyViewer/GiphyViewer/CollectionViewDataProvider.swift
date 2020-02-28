//
//  CollectionViewDataProvider.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

class CollectionViewProvider: NSObject, UICollectionViewDataSource {
	
	var items = [[String]]()
	var supplementaryItems = [String]()
	
	// MARK: - UICollectionViewDataSource
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return supplementaryItems.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items[section].count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath)
		
		if let cell = cell as? ContentCell {
			let item = items[indexPath.section][indexPath.row]
			cell.populate(with: item)
		}
		
		return cell
	}
	
	//    func collectionView(_ collectionView: UICollectionView,
	//                        viewForSupplementaryElementOfKind kind: String,
	//                        at indexPath: IndexPath) -> UICollectionReusableView {
	//
	//        if kind == UICollectionView.elementKindSectionHeader {
	//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
	//                                                                             withReuseIdentifier: "HeaderViewIdentifier",
	//                                                                             for: indexPath)
	//
	//            if let headerView = headerView as? HeaderView {
	//                let item = supplementaryItems[indexPath.section]
	//                headerView.populate(with: item)
	//            }
	//
	//            return headerView
	//        } else {
	//            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
	//                                                                             withReuseIdentifier: "FooterViewIdentifier",
	//                                                                             for: indexPath)
	//
	//            if let footerView = footerView as? FooterView {
	//                let item = supplementaryItems[indexPath.section]
	//                footerView.populate(with: item)
	//            }
	//
	//            return footerView
	//        }
	//    }
}
