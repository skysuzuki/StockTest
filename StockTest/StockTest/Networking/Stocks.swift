//
//  Stocks.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI
import Combine

class Stocks: ObservableObject {

    @Published var prices = [Double]()
    @Published var currentPrice = "...."
    var urlBase = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=IBM&apikey=00HW87JZWQ30BPUN"
    //https://www.alphavantage.co/query?function=TIME_SERIES_DILY&symbol=TESLA&"
    var cancellable: Set<AnyCancellable> = Set()

    //private var apiKey = "apikey=00HW87JZWQ30BPUN"

    //https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=IBM&apikey=demo
    init() {
        fetchStockPrice()
    }

    func fetchStockPrice() {

        //let url = URL(string: urlBase + apiKey)!
        URLSession.shared.dataTaskPublisher(for: URL(string: urlBase)!)
            .map { output in
                return output.data
            }
            .decode(type: StocksDaily.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { _ in
                print("completed")
            }, receiveValue: { value in

                var stockPrices = [Double]()

                let orderedDates = value.timeSeriesDaily?.sorted {
                    guard let d1 = $0.key.stringDate, let d2 = $1.key.stringDate else { return false }
                    return d1 < d2
                }

                guard let stockData = orderedDates else { return }

                for(_, stock) in stockData {
                    if let stock = Double(stock.close) {
                        if stock > 0.0 {
                            stockPrices.append(stock)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.prices = stockPrices
                    self.currentPrice = stockData.last?.value.close ?? ""
                }
            })
            .store(in: &cancellable)
    }
}
