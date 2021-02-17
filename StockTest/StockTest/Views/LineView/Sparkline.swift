//
//  Sparkline.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/17/21.
//

import Foundation
import SwiftUI

struct Sparkline: Shape {

    var points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let sPoints = points.sorted { $0.x < $1.x }

        let maxYCoord = sPoints.map {$0.y}.max() ?? 1
        let maxXCoord = sPoints.map {$0.x}.max() ?? 1

        let xScale: CGFloat = rect.maxX / CGFloat(maxXCoord)
        let yScale: CGFloat = rect.maxY / CGFloat(maxYCoord)

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - (CGFloat(sPoints[0].y * yScale))))

        for item in sPoints.dropFirst() {
            path.addLine(to: CGPoint(x: rect.minX + (item.x * xScale), y: rect.maxY - (item.y * yScale)))
        }
        return path
    }


}
