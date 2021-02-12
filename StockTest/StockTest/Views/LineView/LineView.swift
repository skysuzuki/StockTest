//
//  LineView.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI
import Charts

struct LineView: View {

    let entries: [ChartDataEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Text("Company")
                    .font(.title)
                Text("Price")
                    .font(.body)
                    .offset(x: 5, y: 0)
            }
            Line(entries: entries)
                .padding()
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(entries: [
            ChartDataEntry(x: 1, y: 1),
            ChartDataEntry(x: 2, y: 3),
            ChartDataEntry(x: 3, y: -2),
            ChartDataEntry(x: 4, y: 5),
            ChartDataEntry(x: 5, y: 10),
        ])
    }
}
