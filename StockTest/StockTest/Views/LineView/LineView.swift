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
    //@ObservedObject var stock: Stocks
    var chartDataTest = [ChartDataEntry]()

    //    let symbol: String
    //    let stockName: String
    //    let currPrice: Double
    //    let change: Double
    //    var pri: NSSet

    var stock: Stock

    @ObservedObject var stockNetwork: Stocks = Stocks("CRSR")

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Text(stock.symbol)
                    .font(.caption)
                Text(stock.stockName)
                    .font(.title)
                    .bold()
                Text(String(format: "%.2f", stock.currPrice))
                    .font(.subheadline)
                    .offset(x: 5, y: 0)
                HStack {
                    let changeColor = isPositiveChange() ? Color.green : Color.red
                    Image(systemName: isPositiveChange() ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .foregroundColor(changeColor)
                    let changeString = String(format: "%.2f", stock.change)
                    Text(changeString)
                        .font(.footnote)
                        .foregroundColor(changeColor)
                }
            }
            .offset(x: 20, y: 20)
            VStack(alignment: .center, spacing: 8) {
                Line(prices: prices())
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
            self.stockNetwork.fetchStockPrice(stock.symbol)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func isPositiveChange() -> Bool {
        if stock.change > 0 { return true }
        else { return false }
    }

    private func prices() -> [Double] {
        var result = [Double]()
        if let prices = stock.dailyPrices {
            for price in prices {
                if let priceDescription = price as? Price {
                    result.append(priceDescription.price)
                }
            }
        }
        print(result)
        return result
    }

    private func priceForInterval(_ interval: String) {
        currInterval = interval
        switch interval {
        case "1D":
            self.stockNetwork.fetchStockPrice(stock.symbol)
        case "1M", "3M":
            self.stockNetwork.fetchStockPriceMonthly(stock.symbol, interval)
        case "1Y", "5Y":
            self.stockNetwork.fetchStockPriceYearly(stock.symbol, interval)
        default:
            return
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(stock: Stock())
    }
}
