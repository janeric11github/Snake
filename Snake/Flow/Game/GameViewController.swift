//
//  GameViewController.swift
//  Snake
//
//  Created by Eric on 2021/6/25.
//

import UIKit
import Combine

final class GameViewController: UIViewController {
    private let viewModel: GameViewModel
    
    private var disposeBag = Set<AnyCancellable>()
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupSubviews()
        
        viewModel.$game
            .receive(on: DispatchQueue.main)
            .sink { [weak self] game in
                guard let self = self else { return }
                game.eventPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] event in
                        guard let self = self else { return }
                        switch event {
                        case .didTick(let game): self.gridView.viewModel = .init(game)
                        case .gameOver(_): self.viewModel.showMenu(action: .tryAgain)
                        }
                    }
                    .store(in: &self.disposeBag)
            }
            .store(in: &disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.showMenu(action: .start)
    }
    
    // MARK: - Subviews
    
    private lazy var gridView = GridView(viewModel: .init(viewModel.game))
    
    private func setupSubviews() {
        view.addSubview(gridView)
        gridView.translatesAutoresizingMaskIntoConstraints = false
        gridView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        gridView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        gridView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        gridView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(gridViewDidTap(sender:)))
        gridView.addGestureRecognizer(tap)
    }
    
    @objc func gridViewDidTap(sender: UITapGestureRecognizer) {
        guard viewModel.game.isRunning else { return }
        
        let tapLocation = sender.location(in: gridView)
        let isLeftSide = tapLocation.x < (gridView.bounds.size.width / 2)
        let isTopSide = tapLocation.y < (gridView.bounds.size.height / 2)
        
        let newSnakeDirection: Game.Direction
        switch viewModel.game.snakeDirection {
        case .up,
             .down:
            newSnakeDirection = isLeftSide ? .left : .right
        case .left, .right:
            newSnakeDirection = isTopSide ? .up : .down
        }
        
        viewModel.game.changeSnakeDirection(newSnakeDirection)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

fileprivate extension GridView.ViewModel {
    init(_ game: Game) {
        self.init(cellSize: .init(width: 20, height: 20),
                  gridSize: .init(x: 20, y: 40),
                  overlays: game.gridViewOverlays)
    }
}

fileprivate extension Game {
    var gridViewOverlays: [GridView.ViewModel.Overlay] {
        var overlays = [GridView.ViewModel.Overlay]()
        
        // walls
        
        let wallColor = UIColor.yellow
        let drawWall: (CGRect) -> Void = { cellRect in
            UIBezierPath(rect: cellRect).fill(color: wallColor)
          }
        let wallOverlays: [GridView.ViewModel.Overlay] = walls.map {
            .init(index: .init(x: $0.x, y: $0.y), draw: drawWall)
        }
        
        overlays.append(contentsOf: wallOverlays)
        
        // snake
        
        let snakeColor = UIColor.green
        let drawSnake: (CGRect) -> Void = { cellRect in
            UIBezierPath(rect: cellRect).fill(color: snakeColor)
          }
        let snakeOverlays: [GridView.ViewModel.Overlay] = snake.map {
            .init(index: .init(x: $0.x, y: $0.y), draw: drawSnake)
        }
        
        overlays.append(contentsOf: snakeOverlays)
        
        // snake face
        
        if let snakeHead = snake.first {
            let snakeFaceColor = UIColor.purple
            let drawSnakeFace: (CGRect) -> Void = { [weak self] cellRect in
                guard let self = self else { return }
                let faceRect: CGRect
                switch self.snakeDirection {
                case .up: faceRect = .init(x: cellRect.minX, y: cellRect.minY, width: cellRect.width, height: cellRect.height / 2)
                case .left: faceRect = .init(x: cellRect.minX, y: cellRect.minY, width: cellRect.width / 2, height: cellRect.height)
                case .right: faceRect = .init(x: cellRect.midX, y: cellRect.minY, width: cellRect.width / 2, height: cellRect.height)
                case .down: faceRect = .init(x: cellRect.minX, y: cellRect.midY, width: cellRect.width, height: cellRect.height / 2)
                }
                UIBezierPath(rect: faceRect).fill(color: snakeFaceColor)
              }
            let snakeFaceOverlay: GridView.ViewModel.Overlay =
                .init(index: .init(x: snakeHead.x, y: snakeHead.y), draw: drawSnakeFace)
            
            overlays.append(snakeFaceOverlay)
        }
        
        // food
        
        if let food = food  {
            let foodColorNormal = UIColor.orange
            let foodColorSpeedUp = UIColor.red
            let drawFood: (CGRect) -> Void = { [weak self] cellRect in
                guard let self = self else { return }
                let isGoingToSpeedUp = (self.points % self.speedUpPoints == self.speedUpPoints - 1)
                UIBezierPath(rect: cellRect).fill(color: isGoingToSpeedUp ? foodColorSpeedUp : foodColorNormal)
            }
            let foodOverlay: GridView.ViewModel.Overlay =
                .init(index: .init(x: food.x, y: food.y), draw: drawFood)
            
            overlays.append(foodOverlay)
        }
        
        return overlays
    }
}
