//
//  Grid.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import Foundation

struct Grid {
    struct Size { var x: Int, y: Int }
    struct Index { var x: Int, y: Int }
    
    var size: Size
}

extension Grid.Size {
    static var zero: Self { .init(x: 0, y: 0) }
}

extension Grid {
    func isIndexValid(_ index: Index) -> Bool {
        (0..<size.x).contains(index.x)
            && (0..<size.y).contains(index.y)
    }
}
