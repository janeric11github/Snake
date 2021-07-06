//
//  Coordinator.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import Foundation

protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    var removeFromChildren: (Coordinator) -> Void {
        return { [weak self] target in
            guard let self = self else { return }
            self.children.removeAll { $0 === target }
        }
    }
}
