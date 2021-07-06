//
//  GridView.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import UIKit
import Combine

final class GridView: UIView {
    struct ViewModel {
        struct Overlay {
            var index: Grid.Index
            var draw: ((CGRect) -> Void)?
        }
        var backgroundColor = UIColor.gray
        var lineWidth: CGFloat = 1
        var lineColor = UIColor.black
        var cellSize = CGSize.zero
        var gridSize = Grid.Size.zero
        var overlays = [Overlay]()
    }
    
    @Published
    var viewModel: ViewModel
    
    private var disposeBag = Set<AnyCancellable>()
    
    init(viewModel: ViewModel = .init()) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        $viewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.setNeedsDisplay()
            }
            .store(in: &disposeBag)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // background
        
        UIBezierPath(rect: rect).fill(color: viewModel.backgroundColor)
        
        let totalWidth = viewModel.cellSize.width * CGFloat(viewModel.gridSize.x)
        let totalHeight = viewModel.cellSize.height * CGFloat(viewModel.gridSize.y)
        
        let minX = (bounds.width - totalWidth) / 2
        let minY = (bounds.height - totalHeight) / 2
        
        // lines
        
        for x in 0...Int(viewModel.gridSize.x) {
            let lineX = minX + viewModel.cellSize.width * CGFloat(x)
            UIBezierPath.line(start: .init(x: lineX, y: minY),
                              end: .init(x: lineX, y: minY + totalHeight),
                              width: viewModel.lineWidth)
                .stroke(color: viewModel.lineColor)
        }
        
        for y in 0...Int(viewModel.gridSize.y) {
            let lineY = minY + viewModel.cellSize.height * CGFloat(y)
            UIBezierPath.line(start: .init(x: minX, y: lineY),
                              end: .init(x: minX + totalWidth, y: lineY),
                              width: viewModel.lineWidth)
                .stroke(color: viewModel.lineColor)
        }
        
        viewModel.overlays.forEach { overlay in
            let cellRect = CGRect(origin: .init(x: minX + viewModel.cellSize.width * CGFloat(overlay.index.x),
                                                y: minY + viewModel.cellSize.height * CGFloat(overlay.index.y)),
                                  size: viewModel.cellSize)
            overlay.draw?(cellRect)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

