//
//  SwiftUIView.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/17/21.
//

import SwiftUI
import SwiftUICharts

struct SwiftUIView: View {
    let points: [CGPoint] = [
        CGPoint(x: 0, y: 5),
        CGPoint(x: 3, y: 8),
        CGPoint(x: 2, y: 6),
        CGPoint(x: 4, y: 9),
        CGPoint(x: 5, y: 20),
        CGPoint(x: 6, y: 2)
    ]

    var body: some View {

        Sparkline(points: points)
            .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .frame(width: 250, height: 250)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
