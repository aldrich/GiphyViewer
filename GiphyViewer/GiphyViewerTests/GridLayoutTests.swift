//
//  GridLayoutTests.swift
//  GiphyViewerTests
//
//  Created by Aldrich Co on 3/1/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest
@testable import GiphyViewer

class GridLayoutTests: XCTestCase {

	func testGridLayoutShouldHaveValidStoredProperties() {
		let layout = GridLayoutMock()
		XCTAssertEqual(layout.columnsCount, 2)
	}

	func testGridLayoutWontAddAttributesWithoutCollectionViewAndDelegate() {
		let layout = GridLayoutMock()

		layout.calculateCollectionViewFrames()

		XCTAssertTrue(layout.cachedAttributes.isEmpty)
		XCTAssertTrue(layout.calledFunctions.isEmpty)
	}

	func testGridLayoutAddsAttributesWithValidCollectionViewAndDelegate() {
		let layout = GridLayoutMock()

		layout.contentPadding = ItemsPadding(horizontal: 15, vertical: 15)
		layout.cellsPadding = ItemsPadding(horizontal: 10, vertical: 10)

		let items: [GifObject] = [
			.with(id: "one"),
			.with(id: "two"),
			.with(id: "three"),
			.with(id: "four")
		]

		let supplementaryItems = [""]

		let collectionViewProvider = TrendingGifsCollectionViewProvider()
		collectionViewProvider.items = [items]
		collectionViewProvider.supplementaryItems = supplementaryItems

		let frame = CGRect(x: 0, y: 0, width: 320, height: 568)
		let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
		collectionView.dataSource = collectionViewProvider

		let delegate = PinterestLayoutDelegate()
		layout.delegate = delegate

		layout.calculateCollectionViewFrames()

		XCTAssertEqual(layout.cachedAttributes.count, items.count)
		XCTAssertEqual(layout.calledFunctions.count, supplementaryItems.count * 2)

		let cellsPaddingWidth = CGFloat(layout.columnsCount - 1) * layout.cellsPadding.vertical
		let cellWidth = (layout.contentWidthWithoutPadding - cellsPaddingWidth)
			/ CGFloat(layout.columnsCount)

		let firstCellHeight = delegate.heights[0]

		let firstCellFrame = CGRect(x: layout.contentPadding.horizontal,
									y: layout.contentPadding.vertical,
									width: cellWidth,
									height: firstCellHeight)

		let secondColumnX = layout.contentPadding.horizontal
			+ (cellWidth + layout.cellsPadding.vertical) * CGFloat(layout.columnsCount - 1)

		let secondCellHeight = delegate.heights[1]

		let secondCellFrame = CGRect(x: secondColumnX,
									 y: layout.contentPadding.vertical,
									 width: cellWidth,
									 height: secondCellHeight)

		let thirdCellY = layout.contentPadding.vertical + firstCellHeight
			+ layout.cellsPadding.horizontal

		let thirdCellHeight = delegate.heights[2]

		let thirdCellFrame = CGRect(x: layout.contentPadding.horizontal,
									y: thirdCellY,
									width: cellWidth,
									height: thirdCellHeight)

		let fourthCellY = layout.contentPadding.vertical + secondCellHeight
			+ layout.cellsPadding.horizontal

		let fourthCellHeight = delegate.heights[3]

		let fourthCellFrame = CGRect(x: secondColumnX,
									 y: fourthCellY,
									 width: cellWidth,
									 height: fourthCellHeight)

		let cellsFrames = [firstCellFrame, secondCellFrame, thirdCellFrame, fourthCellFrame]

		for index in 0..<layout.cachedAttributes.count {
			XCTAssertEqual(layout.cachedAttributes[index].frame, cellsFrames[index])
		}

		let height = fourthCellY + fourthCellHeight + layout.contentPadding.vertical
		XCTAssertEqual(layout.contentSize, CGSize(width: frame.size.width, height: height))
	}
}


class GridLayoutMock: GridLayout {
    var calledFunctions = [String]()
    override func addAttributesForSupplementaryView(ofKind kind: String,
													section: Int,
													yOffset: inout CGFloat) {
        calledFunctions.append("addAttributesForSupplementaryView")
    }
}

class PinterestLayoutDelegate: NSObject, LayoutDelegate {

	let heights: [CGFloat] = [60, 120, 80, 100]

    func cellSize(indexPath: IndexPath) -> CGSize {
        let height = heights[indexPath.row]
        return CGSize(width: 0.1, height: height)
    }
}

extension GifObject {
	static func with(id: String) -> GifObject {
		return GifObject(id: id,
						 images: [:], importDatetime: "", title: "",
						 trendingDatetime: "", url: "", username: "")
	}
}
