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

    @State var stock: Stock

    @ObservedObject var stockViewModel: StockListViewModel

    @Binding var stockNetwork: Stocks

    //    @State var ppp: [Double] = []
    //
    //@Binding var lCD: LineChartData

    @State var pointPrices: [CGPoint]

    @Binding var finishedFetching: Bool

    //    let pricesFetch: NSFetchRequest<Price> = Price.fetchRequest()
    //    pricesFetch.predicate = NSPredicate(format: "%K == %@", "\(priceInterval).symbol", symbol)

    //@State var prices: [Double] = []

    var prices: NSOrderedSet?

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
                switch stockViewModel.state {
                case .idle:
                    // Render a clear color and start the loading process
                    // when the view first appears, which should make the
                    // view model transition into its loading state:
                    Color.clear.onAppear {
                        stockViewModel.loadStockPrices(symbol: stock.symbol) }
                case .loading:
                    ProgressView()
                case .failed(let _):
                    EmptyView()
                case .loaded(let points):
                    Line(entries: points)
//                    Sparkline(points: points)
//                        .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
//                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
//                        .padding()

                }
                //                                Line(ppp: $ppp, oP: prices(currInterval), interval: $currInterval)
                //                                Line(entries: [ChartDataEntry]())
                //                                    .padding()
                //                AsyncContentView(source: stockViewModel) { content in

                //                if finishedFetching {
                //                    Sparkline(points: pointPrices)
                //


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
            //self.stockNetwork.fetchStockPrice(stock.symbol)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func isPositiveChange() -> Bool {
        if stock.change > 0 { return true }
        else { return false }
    }

    private func fetchedPrices() -> [Price]?  {
        var prices: [Price]?
        let pricesFetch: NSFetchRequest<Price> = Price.fetchRequest()
        pricesFetch.predicate = NSPredicate(format: "%K == %@", "daily.symbol", stock.symbol)
        let context =  PersistenceController.shared.container.viewContext
        context.performAndWait {
            do {
                //let stocks = try context.fetch(stockFetch)
                prices = try context.fetch(pricesFetch)
            } catch {
                print("Error ")
            }
        }
        return prices
    }

    private func prices(_ interval: String) -> Binding<NSOrderedSet?> {

        switch interval {
        case "1D":
            return $stock.dailyPrices
        //            if let dailyPrices = stock.dailyPrices {
        //                prices = pricesForInterval(intervalPrices: dailyPrices)
        //            }
        case "1W":
            return $stock.weekPrices
        //            if let weeklyPrices = stock.weekPrices {
        //                prices = pricesForInterval(intervalPrices: weeklyPrices)
        //            }
        case "1M":
            return $stock.oneMPrices
        //            if let monthPrices = stock.oneMPrices {
        //                prices = pricesForInterval(intervalPrices: monthPrices)
        //            }
        case "3M":
            return $stock.threeMPrices
        //            if let threeMPrices = stock.threeMPrices {
        //                prices = pricesForInterval(intervalPrices: threeMPrices)
        //            }
        case "1Y":
            return $stock.oneYPrices
        //            if let yearPrices = stock.oneYPrices {
        //                prices = pricesForInterval(intervalPrices: yearPrices)
        //            }
        case "5Y":
            return $stock.fiveYPrices
        //            if let fiveYPrices = stock.fiveYPrices {
        //                prices = pricesForInterval(intervalPrices: fiveYPrices)
        //            }
        default:
            return $stock.dailyPrices
        }
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
        case "1W":
            self.stockViewModel.loadStockWeeklyPrices(symbol: stock.symbol)
        case "1M", "3M":
            self.stockViewModel.loadMonthlyStockPrices(symbol: stock.symbol, interval: interval)
        case "1Y", "5Y":
            self.stockViewModel.loadYearlyStockPrices(symbol: stock.symbol, interval: interval)
        default:
            self.stockViewModel.loadStockPrices(symbol: stock.symbol)
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(stock: Stock(), stockViewModel: StockListViewModel(), stockNetwork: .constant(Stocks()), pointPrices: [CGPoint](), finishedFetching: .constant(false))
    }
}
