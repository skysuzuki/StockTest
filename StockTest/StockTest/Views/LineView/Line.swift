//
//  Line.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI

struct Line: View {
    var data: [(Double)]
    @Binding var frame: CGRect

    let padding: CGFloat = 30

    var stepWidth: CGFloat {
        if data.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(data.count - 1)
    }

    var stepHeight: CGFloat {
        var min: Double?
        var max: Double?
        let points = self.data

        if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
            min = minPoint
            max = maxPoint
        } else {
            return 0
        }

        if let min = min, let max = max, min != max {
            if min <= 0 {
                return (frame.size.height - padding) / CGFloat(max - min)
            } else {
                return (frame.size.height - padding) / CGFloat(max + min)
            }
        }

        return 0
    }

    var path: Path {
        let points = self.data
        return Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }

    var body: some View {
        ZStack {
            self.path
                .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(
                    .degrees(180), axis: (x: 0, y: 1, z: 0))
                .drawingGroup()
        }
    }
}

//struct Line_Previews: PreviewProvider {
//    static var previews: some View {
//        Line(data: [], frame: <#Binding<CGRect>#>)
//    }
//}
