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

    var stock: Stock

    @Binding var stockNetwork: Stocks

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
                Line(prices: prices(currInterval))
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

    private func prices(_ interval: String) -> [Double] {
        switch interval {
        case "1D":
            if let prices = stock.dailyPrices {
                return pricesForInterval(intervalPrices: prices)
            }
        case "1W":
            if let prices = stock.weekPrices {
                return pricesForInterval(intervalPrices: prices)
            }
        case "1M":
            if let prices = stock.oneMPrices {
                return pricesForInterval(intervalPrices: prices)
            }
        case "3M":
            if let prices = stock.threeMPrices {
                return pricesForInterval(intervalPrices: prices)
            }
        case "1Y":
            if let prices = stock.oneYPrices {
                return pricesForInterval(intervalPrices: prices)
            }
        case "5Y":
            if let prices = stock.fiveYPrices {
                return pricesForInterval(intervalPrices: prices)
            }
        default:
            return [Double]()
        }
        return [Double]()
    }

    private func pricesForInterval(intervalPrices: NSOrderedSet) -> [Double] {
        var prices = [Double]()
        for price in intervalPrices {
            if let price = price as? Price {
                prices.append(price.price)
            }
        }
        return prices
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
        LineView(stock: Stock(), stockNetwork: .constant(Stocks()))
    }
}
