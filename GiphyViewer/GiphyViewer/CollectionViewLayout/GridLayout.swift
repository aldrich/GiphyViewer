//
//  GridLayout.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import UIKit

public class GridLayout: BaseLayout {
	
	public var columnsCount = 2
	
	override public func calculateCollectionViewFrames() {
		
		guard columnsCount > 0 else {
			fatalError("Value must be greater than zero")
		}
		
		guard let collectionView = collectionView, let delegate = delegate else {
			return
		}
		
		contentSize.width = collectionView.frame.size.width
		
		let cellsPaddingWidth = CGFloat(columnsCount - 1) * cellsPadding.vertical
		let cellWidth = (contentWidthWithoutPadding - cellsPaddingWidth) / CGFloat(columnsCount)
		
		var yOffsets = [CGFloat](repeating: contentPadding.vertical, count: columnsCount)
		
		for section in 0 ..< collectionView.numberOfSections {
			
			addAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
											  section: section,
											  yOffsets: &yOffsets)
			
			let itemsCount = collectionView.numberOfItems(inSection: section)
			
			for item in 0 ..< itemsCount {
				let isLastItem = item == itemsCount - 1
				let indexPath = IndexPath(item: item, section: section)
				
				let cellhHeight = delegate.cellSize(indexPath: indexPath).height
				let cellSize = CGSize(width: cellWidth, height: cellhHeight)
				
				let y = yOffsets.min()!
				let column = yOffsets.firstIndex(of: y)!
				let x = CGFloat(column) * (cellWidth + cellsPadding.horizontal) + contentPadding.horizontal
				let origin = CGPoint(x: x, y: y)
				
				let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
				attributes.frame = CGRect(origin: origin, size: cellSize)
				cachedAttributes.append(attributes)
				
				yOffsets[column] += cellhHeight + cellsPadding.vertical
				
				if isLastItem {
					let y = yOffsets.max()!
					for index in 0..<yOffsets.count {
						yOffsets[index] = y
					}
				}
			}
			
			addAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
											  section: section,
											  yOffsets: &yOffsets)
		}
		
		contentSize.height = yOffsets.max()! + contentPadding.vertical - cellsPadding.vertical
	}
}
