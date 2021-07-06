//
//  GameViewModel.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import Foundation
import Combine

final class GameViewModel {
    enum Action { case start, tryAgain }
    
    private let showMenuHandler: (GameViewModel, Action) -> Void
    
    @Published
    private(set) var game = Game.default
    
    init(showMenuHandler: @escaping (GameViewModel, Action) -> Void) {
        self.showMenuHandler = showMenuHandler
    }
    
    func showMenu(action: Action) {
        showMenuHandler(self, action)
    }
    
    func handleAction(action: Action) {
        switch action {
        case .start: break
        case .tryAgain: game = Game.default
        }
        game.start()
    }
}

fileprivate extension Game {
    static var `default`: Self {
        let grid = Grid(size: .init(x: 20, y: 40))
        var walls = Set<Game.Position>()
        for x in 0..<grid.size.x {
            walls.insert(.init(x: x, y: 0))
            walls.insert(.init(x: x, y: grid.size.y - 1))
        }
        for y in 0..<grid.size.y {
            walls.insert(.init(x: 0, y: y))
            walls.insert(.init(x: grid.size.x - 1, y: y))
        }
        return .init(grid: grid,
                     snakeDirection: .up,
                     snake: [.init(x: 10, y: 20),
                             .init(x: 10, y: 21),
                             .init(x: 10, y: 22)],
                     walls: walls,
                     tickInterval: 0.2,
                     speedUpPoints: 3,
                     tickIntervalSpeedUpRatio: 0.9)
    }
}
