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

    //@State var dataToShow = \Stocks.prices


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
        VStack(alignment: .center, spacing: 8) {
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
        .onAppear() {
            self.stock.fetchStockPrice(stock.id)
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
