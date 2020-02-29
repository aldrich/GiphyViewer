//
//  Coordinator.swift
//  GiphyViewer
//
//  Created by Aldrich Co on 2/29/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var parentCoordinator: Coordinator? { get set }

    func start()
    func start(coordinator: Coordinator)
    func didFinish(coordinator: Coordinator)
    func removeChildCoordinators()
}

class BaseCoordinator: Coordinator {

    var navigationController = UINavigationController()
    var childCoordinators = [Coordinator]()
    var parentCoordinator: Coordinator?

    func start() {
        fatalError("Start method should be implemented.")
    }

    func start(coordinator: Coordinator) {
        self.childCoordinators += [coordinator]
        coordinator.parentCoordinator = self
        coordinator.start()
    }

    func removeChildCoordinators() {
        self.childCoordinators.forEach { $0.removeChildCoordinators() }
        self.childCoordinators.removeAll()
    }

    func didFinish(coordinator: Coordinator) {
        if let index = self.childCoordinators.firstIndex(where: { $0 === coordinator }) {
            self.childCoordinators.remove(at: index)
        }
    }
}

enum ViewControllerUtils {

    static func setRootViewController(window: UIWindow, viewController: UIViewController, withAnimation: Bool) {

        if !withAnimation {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
            return
        }

        if let snapshot = window.snapshotView(afterScreenUpdates: true) {
            viewController.view.addSubview(snapshot)
            window.rootViewController = viewController
            window.makeKeyAndVisible()

            UIView.animate(withDuration: 0.4, animations: {
                snapshot.layer.opacity = 0
            }, completion: { _ in
                snapshot.removeFromSuperview()
            })
        }
    }
}
