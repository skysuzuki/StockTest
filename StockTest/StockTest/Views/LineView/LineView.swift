//
//  LineView.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI
import Charts

struct LineView: View {

    @State private var interval = "1D"
    var intervals = [
        "1D",
        "1W",
        "1M",
        "3M",
        "1Y",
        "5Y"]
    @ObservedObject var stock: Stocks
    var chartDataTest = [ChartDataEntry]()
    //var prices: [Double]
    init(stock: Stocks) {
        self.stock = stock
        //stock.fetchStockPriceDaily(stock.id, .daily) {}
        //self.stock.fetchStockPrice(stock.id, .intraday)
        //createChartData()
        UISegmentedControl.appearance().selectedSegmentTintColor = .green
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
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
            .offset(x: 10, y: 20)
            Line(prices: stock.prices)
                .padding()
            Picker(selection: $interval, label: Text("")) {
                ForEach(intervals, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
        .onAppear() {
            self.stock.fetchStockPrice(stock.id, .intraday)
        }
    }

    private mutating func createChartData() {
        if interval == "1M" {
            print("1M SELECTED")
//            stock.fetchStockPriceDaily(stock.id, .daily) {
//                for i in 0..<stock.prices.count {
//                    chartDataTest.append(ChartDataEntry(x: Double(i), y: stock.prices[i]))
//                }
//            }
            //self.stock.fetchStockPrice(stock.id, .intraday)
            //stock.fetchStockPriceDaily(stock.id, .daily)
        }
    }

    private func priceForInterval() {


    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(stock: Stocks("CRSR"))
    }
}
