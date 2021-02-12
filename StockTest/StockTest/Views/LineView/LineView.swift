//
//  LineView.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI
import Charts

struct LineView: View {

    @State private var currInterval = "1D"
    var intervals = [
        "1D",
        "1W",
        "1M",
        "3M",
        "1Y",
        "5Y"]
    @ObservedObject var stock: Stocks
    var chartDataTest = [ChartDataEntry]()

    init(stock: Stocks) {
        self.stock = stock
        UISegmentedControl.appearance().selectedSegmentTintColor = .green
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Text(stock.id)
                    .font(.caption)
                Text(stock.getStockFullName(stock.id))
                    .font(.title)
                    .bold()
                Text(String(format: "%.2f", stock.currentPrice))
                    .font(.subheadline)
                    .offset(x: 5, y: 0)
                HStack {
                    let changeColor = isPositiveChange() ? Color.green : Color.red
                    Image(systemName: isPositiveChange() ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .foregroundColor(changeColor)
                    let changeString = String(format: "%.2f", Float(stock.stockView?.change ?? "0.00")!)
                    Text(changeString)
                        .font(.footnote)
                        .foregroundColor(changeColor)
                }
            }
            .offset(x: 20, y: 20)
            VStack(alignment: .center, spacing: 8) {
                Line(prices: stock.prices)
                    .padding()
                HStack(alignment: .center) {
                    ForEach(intervals, id: \.self) { interval in
                        Button(action: {
                            priceForInterval(interval)
                        }, label: {
                            Text(interval)
                                .font(.system(size: 15))
                                .foregroundColor(interval == currInterval ? Color.white
                                    : Color.green)
                                .animation(nil)
                        })
                        .frame(width: 35)
                        .padding(5)
                        .background(interval == currInterval
                                        ? Color.green
                                        : Color.white)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear() {
            self.stock.fetchStockPrice(stock.id)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func isPositiveChange() -> Bool {
        if let stockView = stock.stockView,
           let change = Double(stockView.change) {
            if change > 0 { return true }
            else { return false }
        } else {
            return false
        }
    }

    private func priceForInterval(_ interval: String) {
        currInterval = interval
        switch interval {
        case "1D":
            self.stock.fetchStockPrice(stock.id)
        case "1M", "3M":
            stock.fetchStockPriceMonthly(stock.id, interval)
        case "1Y", "5Y":
            stock.fetchStockPriceYearly(stock.id, interval)
        default:
            return
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(stock: Stocks("CRSR"))
    }
}
