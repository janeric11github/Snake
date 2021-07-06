//
//  MenuViewModel.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import Foundation
import Combine

final class MenuViewModel {
    struct Action {
        var title: String?
        var handler: (() -> Void)?
    }
    
    @Published
    private(set) var action: Action
    
    init(action: Action) {
        self.action = action
    }
    
    func selectAction() {
        action.handler?()
    }
}
