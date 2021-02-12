//
//  LineView.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI
import Charts

struct LineView: View {

    let stock: Stocks
    //var prices: [Double]
    init(stock: Stocks) {
        self.stock = stock
        self.stock.fetchStockPrice(stock.id, .intraday)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Text(stock.id)
                    .font(.title)
                Text("\(stock.currentPrice)")
                    .font(.body)
                    .offset(x: 5, y: 0)
            }
            .padding()
            let entries = createChartData(prices: stock.prices)
            Line(entries: entries)
                .padding()
        }
    }

    private func createChartData(prices: [Double]) -> [ChartDataEntry] {
        var chartData = [ChartDataEntry]()
        for i in 0..<prices.count {
            chartData.append(ChartDataEntry(x: Double(i), y: prices[i]))
        }
        return chartData
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(stock: Stocks("CRSR"))
    }
}
