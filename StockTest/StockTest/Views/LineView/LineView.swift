//
//  LineView.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI
import Charts
import CoreData

struct LineView: View {

    @State private var currInterval = "1D"
    var intervals = [
        "1D",
        "1W",
        "1M",
        "3M",
        "1Y",
        "5Y"]

    //var stock: Stock
    var stockView: StockView
    var stockName: String

    @State var chartPrice: String
    @ObservedObject var stockViewModel: StockListViewModel
    

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Text(stockView.symbol)
                    .font(.caption)
                Text(stockName)
                    .font(.title)
                    .bold()
                //Text(String(format: "%.2f", stock.currPrice))
                Text(chartPrice)
                    .font(.subheadline)
                    .offset(x: 5, y: 0)
                HStack {
                    let changeColor = isPositiveChange() ? Color.green : Color.red
                    Image(systemName: isPositiveChange() ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .foregroundColor(changeColor)
                    //let changeString = String(format: "%.2f", stock.change)
                    Text(stockView.change)
                        .font(.footnote)
                        .foregroundColor(changeColor)
                }
            }
            .offset(x: 20, y: 20)
            VStack(alignment: .center, spacing: 8) {
                switch stockViewModel.state {
                case .idle:
                    // Render a clear color and start the loading process
                    // when the view first appears, which should make the
                    // view model transition into its loading state:
                    Color.clear.onAppear {
                        //stockViewModel.loadStockPrices(symbol: stock.symbol)
                    }
                case .loading:
                    ProgressView()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                case .failed(let _):
                    EmptyView()
                case .loaded(let points):
                    Line(entries: points,
                         chartValue: $chartPrice)
                }
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
            stockViewModel.loadStockPrices(symbol: stockView.symbol)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func isPositiveChange() -> Bool {
        if let change = Double(stockView.change) {
            if change > 0 { return true }
        }
        return false
    }

    private func priceForInterval(_ interval: String) {
        currInterval = interval
        switch interval {
        case "1W":
            self.stockViewModel.loadStockWeeklyPrices(symbol: stockView.symbol)
        case "1M", "3M":
            self.stockViewModel.loadMonthlyStockPrices(symbol: stockView.symbol, interval: interval)
        case "1Y", "5Y":
            self.stockViewModel.loadYearlyStockPrices(symbol: stockView.symbol, interval: interval)
        default:
            self.stockViewModel.loadStockPrices(symbol: stockView.symbol)
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(
            stockView: StockView(
                symbol: "",
                price: "",
                change: "",
                changePercent: ""),
            stockName: "Corsair",
            chartPrice: "0.0",
            stockViewModel: StockListViewModel())
    }
}
