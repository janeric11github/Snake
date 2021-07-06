//
//  Utility.swift
//  Snake
//
//  Created by Eric on 2021/7/6.
//

import UIKit

extension UIBezierPath {
    static func line(start: CGPoint, end: CGPoint, width: CGFloat, dashes: [CGFloat]? = nil) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = width
        path.setLineDash(dashes, count: 1, phase: 0)
        return path
    }
    
    func stroke(color: UIColor) {
        color.setStroke()
        stroke()
    }
    
    func fill(color: UIColor) {
        color.setFill()
        fill()
    }
}
