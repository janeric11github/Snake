//
//  MainCoordinator.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import UIKit

final class MainCoordinator: Coordinator {
    var children = [Coordinator]()
    
    private let windowScene: UIWindowScene
    
    private lazy var window = UIWindow(windowScene: windowScene)
    
    init(windowScene: UIWindowScene) {
        self.windowScene = windowScene
    }
    
    func start() {
        showGame()
    }
    
    private func showGame() {
        let gameCoordinator = GameCoordinator(window: window)
        gameCoordinator.start()
        
        children.append(gameCoordinator)
        
        window.makeKeyAndVisible()
    }
}
