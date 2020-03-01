//
//  GiphyViewerTests.swift
//  GiphyViewerTests
//
//  Created by Aldrich Co on 2/28/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest
@testable import GiphyViewer

class BaseLayoutTests: XCTestCase {

	func testItemPaddingShouldHaveValidProperties() {
		let padding = ItemsPadding()
		XCTAssertEqual(padding.horizontal, 0)
		XCTAssertEqual(padding.vertical, 0)
	}

	func testBaseLayoutShouldHaveValidProperties() {
		let layout = BaseLayout()
		XCTAssertEqual(layout.contentPadding.horizontal, 0)
		XCTAssertEqual(layout.contentPadding.vertical, 0)

		XCTAssertEqual(layout.cellsPadding.horizontal, 0)
		XCTAssertEqual(layout.cellsPadding.vertical, 0)

		XCTAssertNil(layout.delegate)
		XCTAssertTrue(layout.cachedAttributes.isEmpty)
		XCTAssertEqual(layout.contentSize, .zero)
	}

	func testBaseLayoutShouldHaveValidComputedProperties() {

		let layout = BaseLayout()
		XCTAssertEqual(layout.contentWidthWithoutPadding, 0)
		XCTAssertEqual(layout.collectionViewContentSize, .zero)

		let contentHorizontalPadding = CGFloat(15)
		layout.contentPadding = ItemsPadding(horizontal: contentHorizontalPadding, vertical: 0)

		let width = CGFloat(320)
		let height = CGFloat(568)
		layout.contentSize = CGSize(width: width, height: height)

		XCTAssertEqual(layout.contentWidthWithoutPadding, width - 2 * contentHorizontalPadding)
		XCTAssertEqual(layout.collectionViewContentSize, layout.contentSize)
	}

	func testBaseLayoutShouldReturnAttributesInRect() {

		let layout = BaseLayout()
		let side = CGFloat(5)
		let rect = CGRect(x: side - 1, y: side - 1, width: side, height: side)

		let attributesInRect = UICollectionViewLayoutAttributes()
		attributesInRect.frame = CGRect(x: 0, y: 0, width: side, height: side)

		let outOfRectPoint = side * 2
		let attributesOutOfRect = UICollectionViewLayoutAttributes()

		attributesOutOfRect.frame = CGRect(x: outOfRectPoint,
										   y: outOfRectPoint,
										   width: side,
										   height: side)

		layout.cachedAttributes = [attributesInRect, attributesOutOfRect]
		let attributes = layout.layoutAttributesForElements(in: rect)

		XCTAssertTrue(attributes?.contains(attributesInRect) ?? false)
	}

	func testBaseLayoutShouldNotAddAttributesWhenDelegateNotSet() {
		let layout = BaseLayout()

		var yOffset = CGFloat(15)
		layout.addAttributesForSupplementaryView(ofKind: "kind",
												 section: 0,
												 yOffset: &yOffset)
		XCTAssertTrue(layout.cachedAttributes.isEmpty)
	}

	func testBaseLayoutShouldNotAddAttributesWhenDelegateHasNoImplementedMethods() {
		let layout = BaseLayout()

		let delegate = BaseLayoutDelegate()
		layout.delegate = delegate

		var yOffset = CGFloat(15)
		layout.addAttributesForSupplementaryView(ofKind: "kind",
												 section: 0,
												 yOffset: &yOffset)

		XCTAssertTrue(layout.cachedAttributes.isEmpty)
	}

	func testBaseLayoutShouldNotAddAttributesWhenDelegateHasHeightMethodsOnly() {
		let layout = BaseLayout()

		let heightDelegate = HeightLayoutDelegate()
		layout.delegate = heightDelegate

		let contentHorizontalPadding = CGFloat(15)
		layout.contentPadding = ItemsPadding(horizontal: contentHorizontalPadding, vertical: 15)
		layout.cellsPadding = ItemsPadding(horizontal: 10, vertical: 10)
		layout.contentSize = CGSize(width: 320, height: 568)

		let section = 0
		let originalYOffset = CGFloat(15)
		var yOffset = originalYOffset
		layout.addAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
												 section: section,
												 yOffset: &yOffset)

		let attributes = layout.cachedAttributes.first!
		let headerHeight = heightDelegate.headerHeight(indexPath: attributes.indexPath)

		XCTAssertEqual(layout.cachedAttributes.count, 1)
		XCTAssertEqual(attributes.representedElementKind!, UICollectionView.elementKindSectionHeader)
		XCTAssertEqual(attributes.indexPath.section, section)
		XCTAssertEqual(attributes.frame, CGRect(x: contentHorizontalPadding,
												y: originalYOffset,
												width: layout.contentWidthWithoutPadding,
												height: headerHeight))
		XCTAssertEqual(yOffset, originalYOffset + headerHeight + layout.cellsPadding.vertical)
	}

	func testBaseLayoutShouldAddAttributesWhenDelegateHaveAllMethodsImplemented() {

		let layout = BaseLayout()

		let hwDelegate = HeightWidthLayoutDelegate()
		layout.delegate = hwDelegate
		layout.contentPadding = ItemsPadding(horizontal: 15, vertical: 15)
		layout.cellsPadding = ItemsPadding(horizontal: 10, vertical: 10)
		layout.contentSize = CGSize(width: 320, height: 568)

		let section = 0
		let originalYOffset = CGFloat(15)
		var yOffset = originalYOffset
		layout.addAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
												 section: section,
												 yOffset: &yOffset)

		let attributes = layout.cachedAttributes.first!
		let footerHeight = hwDelegate.footerHeight(indexPath: attributes.indexPath)
		let footerWidth = hwDelegate.footerWidth(indexPath: attributes.indexPath)

		XCTAssertEqual(layout.cachedAttributes.count, 1)
		XCTAssertEqual(attributes.representedElementKind!, UICollectionView.elementKindSectionFooter)
		XCTAssertEqual(attributes.indexPath.section, section)
		XCTAssertEqual(attributes.frame, CGRect(x: layout.contentSize.width / 2 - footerWidth / 2,
												y: originalYOffset,
												width: footerWidth,
												height: footerHeight))
		XCTAssertEqual(yOffset, originalYOffset + footerHeight + layout.cellsPadding.vertical)
	}

	func testCustomLayoutPreparations() {
		let layout = CustomLayout()
		let attributes = UICollectionViewLayoutAttributes()
		layout.cachedAttributes = [attributes]
		layout.prepare()
		XCTAssertTrue(layout.cachedAttributes.isEmpty)
		XCTAssertTrue(layout.calledFunctions.contains("calculateCollectionViewFrames"))
	}

	func testCustomLayoutShouldAddAttributesForSupplementaryView() {
		let layout = CustomLayout()
		var yOffsets: [CGFloat] = [15, 10, 10]
		layout.addAttributesForSupplementaryView(ofKind: "kind", section: 0, yOffsets: &yOffsets)
		XCTAssertTrue(layout.calledFunctions.contains("addAttributesForSupplementaryView"))
		XCTAssertEqual(yOffsets, [15, 15, 15])
	}
}

class BaseLayoutDelegate: LayoutDelegate {
	func cellSize(indexPath: IndexPath) -> CGSize {
		return CGSize(width: 100, height: 150)
	}
}

class HeightLayoutDelegate: BaseLayoutDelegate {
	func headerHeight(indexPath: IndexPath) -> CGFloat {
		return 44
	}
}

class HeightWidthLayoutDelegate: HeightLayoutDelegate {
	func footerHeight(indexPath: IndexPath) -> CGFloat {
		return 50
	}

	func footerWidth(indexPath: IndexPath) -> CGFloat {
		return 150
	}
}

class CustomLayout: BaseLayout {
	var calledFunctions = [String]()

	override func calculateCollectionViewFrames() {
		calledFunctions.append("calculateCollectionViewFrames")
	}

	override func addAttributesForSupplementaryView(ofKind kind: String, section: Int, yOffset: inout CGFloat) {
		calledFunctions.append("addAttributesForSupplementaryView")
	}
}
