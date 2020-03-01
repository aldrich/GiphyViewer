//
//  CoordinatorTests.swift
//  GiphyViewerTests
//
//  Created by Aldrich Co on 3/1/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest
@testable import GiphyViewer

class CoordinatorTests: XCTestCase {

    func testBaseCoordinatorInitialProperties() {
        let baseCoordinator = BaseCoordinator()

		// children are empty, parent is nil
		XCTAssertTrue(baseCoordinator.childCoordinators.isEmpty)
		XCTAssertNil(baseCoordinator.parentCoordinator)
    }

	func testBaseCoordinatorHandlesChildrenCorrectly() {

		let parentCoordinator = BaseCoordinator()

		let childCoordinator1 = MockCoordinator()
		let childCoordinator2 = MockCoordinator()

		parentCoordinator.start(coordinator: childCoordinator1)
		parentCoordinator.start(coordinator: childCoordinator2)

		XCTAssert(parentCoordinator.childCoordinators.first === childCoordinator1)
		XCTAssert(parentCoordinator.childCoordinators.last === childCoordinator2)

		XCTAssert(childCoordinator1.parentCoordinator === parentCoordinator)
		XCTAssert(childCoordinator2.parentCoordinator === parentCoordinator)

		XCTAssertTrue(childCoordinator1.startCalled)
		XCTAssertTrue(childCoordinator2.startCalled)

		// child1 finished
		parentCoordinator.didFinish(coordinator: childCoordinator1)
		XCTAssertTrue(parentCoordinator.childCoordinators.first === childCoordinator2)

		parentCoordinator.removeChildCoordinators()
		XCTAssertTrue(parentCoordinator.childCoordinators.isEmpty)
	}

	func testAppCoordinatorStartsTrendingGifsCoordinator() {
		let appCoordinator = AppCoordinator()
		appCoordinator.start()

		XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
		XCTAssert(appCoordinator.childCoordinators.first is TrendingGifsListCoordinator)

		let trendsCoordinator = appCoordinator.childCoordinators.first

		// start a second time (the same result, just a different TrendGifsCoordinator)
		appCoordinator.start()

		XCTAssertEqual(appCoordinator.childCoordinators.count, 1)
		XCTAssert(appCoordinator.childCoordinators.first is TrendingGifsListCoordinator)

		XCTAssert(appCoordinator.childCoordinators.first !== trendsCoordinator)
	}

	func testTrendingGifsCoordinator() {
		let viewModel = TrendingGifsViewModel(networking: GiphyAPIClient())
		let coordinator = TrendingGifsListCoordinator(viewModel: viewModel)

		coordinator.start()

		let navController = coordinator.navigationController
		XCTAssertEqual(navController.viewControllers.count, 1)
		XCTAssert(navController.viewControllers.first is TrendingGifsViewController)

		// this triggers 'showDetail'
		let gifObject = GifObject.with(id: "id1")
		viewModel.selectedGif?(gifObject)
		XCTAssertEqual(navController.viewControllers.count, 2)
		XCTAssert(navController.viewControllers.last is GifDetailViewController)
	}
}

class MockCoordinator: BaseCoordinator {

	var startCalled = false

	override func start() {
		startCalled = true
	}
}
