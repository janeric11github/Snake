//
//  GameCoordinator.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import UIKit

final class GameCoordinator: Coordinator {
    var children = [Coordinator]()
    
    private let window: UIWindow
    
    private weak var gameViewController: GameViewController?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let gameViewModel = GameViewModel(showMenuHandler: { [weak self] viewModel, action in
            guard let self = self else { return }
            self.showMenu(action: .init(title: action.title, handler: { viewModel.handleAction(action: action) }))
        })
        let gameViewController = GameViewController(viewModel: gameViewModel)
        window.rootViewController = gameViewController
        
        self.gameViewController = gameViewController
    }
    
    private func showMenu(action: MenuCoordinator.Action) {
        guard let gameViewController = gameViewController else { return }

        let menuCoordinator = MenuCoordinator(presenter: gameViewController,
                                              action: action,
                                              finishHandler: removeFromChildren)
        menuCoordinator.start()
        
        children.append(menuCoordinator)
    }
}

fileprivate extension GameViewModel.Action {
    var title: String? {
        switch self {
        case .start: return "Start"
        case .tryAgain: return "Try Again"
        }
    }
}
