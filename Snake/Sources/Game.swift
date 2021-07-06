//
//  Game.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import Foundation
import Combine

final class Game {
    enum Event {
        case didTick(Game)
        case gameOver(Game)
    }
    enum Direction { case up, left, right, down }
    struct Position: Hashable { var x: Int, y: Int }
    
    var isRunning: Bool { timer?.isValid ?? false }
    
    private(set) var points = 0
    
    let grid: Grid
    
    private(set) var snakeDirection: Direction
    private(set) var snake: [Position]
    private(set) var walls: Set<Position>
    private(set) var food: Position?
    
    private(set) var tickInterval: TimeInterval
    private(set) var speedUpPoints: Int
    private(set) var tickIntervalSpeedUpRatio: Double
    
    let eventPublisher = PassthroughSubject<Event, Never>()
    
    private var newSnakeDirection: Direction
    private var timer: Timer?
    
    init(grid: Grid,
         snakeDirection: Direction,
         snake: [Position],
         walls: Set<Position>,
         tickInterval: TimeInterval,
         speedUpPoints: Int,
         tickIntervalSpeedUpRatio: Double) {
        self.grid = grid
        self.snakeDirection = snakeDirection
        self.snake = snake
        self.walls = walls
        self.tickInterval = tickInterval
        self.speedUpPoints = speedUpPoints
        self.tickIntervalSpeedUpRatio = tickIntervalSpeedUpRatio
        self.newSnakeDirection = snakeDirection
    }
    
    func start() {
        guard !isRunning else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.tick()
        }
    }
    
    func stop() {
        guard isRunning else { return }
        
        timer?.invalidate()
    }
    
    func changeSnakeDirection(_ direction: Direction) {
        guard direction != snakeDirection.opposite else { return }
        newSnakeDirection = direction
    }
    
    func tick() {
        guard isRunning else { return }
        
        defer { eventPublisher.send(.didTick(self)) }
        
        guard let head = snake.first else {
            print("snake is empty")
            return
        }
        
        snakeDirection = newSnakeDirection
        let nextHead = head.next(snakeDirection)
        
        guard (0..<grid.size.x).contains(nextHead.x),
              (0..<grid.size.y).contains(nextHead.y) else {
            print("out of bounds")
            handleGameOver()
            return
        }
        
        guard !snake.contains(nextHead) else {
            print("bump into snake")
            handleGameOver()
            return
        }
        
        guard !walls.contains(nextHead) else {
            print("bump into wall")
            handleGameOver()
            return
        }
        
        let isContactingFood = (food == nextHead)
        if isContactingFood {
            consumeFood()
        }
        
        moveSnake(nextHead: nextHead, shouldGrow: isContactingFood)
        
        generateFoodIfNeeded()
    }
    
    private func consumeFood() {
        points += 1
        food = nil
        
        if speedUpPoints != 0,
           points % speedUpPoints == 0 {
            speedUp()
        }
    }
    
    private func speedUp() {
        tickInterval *= tickIntervalSpeedUpRatio
        stop()
        start()
    }
    
    private func moveSnake(nextHead: Position, shouldGrow: Bool) {
        snake.insert(nextHead, at: 0)
        guard !shouldGrow else { return }
        snake.removeLast()
    }
    
    private func generateFoodIfNeeded() {
        guard food == nil else { return }
        
        var newFood: Position?
        for position in allPositions.shuffled() {
            guard !snake.contains(position),
                  !walls.contains(position),
                  food != position else { continue }
            newFood = position
            break
        }
        
        guard let newFood = newFood else {
            print("no space for new food")
            return
        }
        
        food = newFood
    }
    
    private func handleGameOver() {
        stop()
        eventPublisher.send(.gameOver(self))
    }
}

extension Game.Position {
    func next(_ direction: Game.Direction) -> Self {
        switch direction {
        case .up: return .init(x: x, y: y - 1)
        case .left: return .init(x: x - 1, y: y)
        case .right: return .init(x: x + 1, y: y)
        case .down: return .init(x: x, y: y + 1)
        }
    }
}

extension Game.Direction {
    var opposite: Self {
        switch self {
        case .up: return .down
        case .left: return .right
        case .right: return .left
        case .down: return .up
        }
    }
}

extension Game {
    var allPositions: Set<Position> {
        var positions = Set<Position>()
        for x in 0..<grid.size.x {
            for y in 0..<grid.size.y {
                positions.insert(.init(x: x, y: y))
            }
        }
        return positions
    }
}
