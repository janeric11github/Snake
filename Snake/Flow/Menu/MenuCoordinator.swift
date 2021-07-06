//
//  MenuCoordinator.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import UIKit
import Combine

import UIKit

final class MenuCoordinator: Coordinator {
    struct Action {
        var title: String?
        var handler: (() -> Void)?
    }
    
    var children = [Coordinator]()
    
    private let presenter: UIViewController
    private let action: Action
    private let finishHandler: (MenuCoordinator) -> Void
    
    init(presenter: UIViewController,
         action: Action,
         finishHandler: @escaping (MenuCoordinator) -> Void) {
        self.presenter = presenter
        self.action = action
        self.finishHandler = finishHandler
    }
    
    func start() {
        let menuViewModel = MenuViewModel(action: .init(title: action.title) { [weak self] in
            guard let self = self else { return }
            self.action.handler?()
            self.finish()
        })
        let menuViewController = MenuViewController(viewModel: menuViewModel)
        menuViewController.modalPresentationStyle = .pageSheet
        menuViewController.modalTransitionStyle = .crossDissolve
        menuViewController.isModalInPresentation = true
        presenter.present(menuViewController, animated: true)
    }
    
    private func finish() {
        presenter.dismiss(animated: true)
        finishHandler(self)
    }
}
