//
//  SceneDelegate.swift
//  Snake
//
//  Created by Eric on 2021/6/25.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private(set) var mainCoordinator: MainCoordinator?
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let mainCoordinator = MainCoordinator(windowScene: windowScene)
        mainCoordinator.start()
        
        self.mainCoordinator = mainCoordinator
    }
}
