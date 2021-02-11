//
//  Stocks.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI
import Combine

class Stocks: ObservableObject {

    @Published var stockViews = [StockView]()
    @Published var prices = [Double]()
    @Published var currentPrice = "...."
    var urlBase = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=IBM&apikey=00HW87JZWQ30BPUN"
    var baseURL = URL(string: "https://www.alphavantage.co/query?")!
    //https://www.alphavantage.co/query?function=TIME_SERIES_DILY&symbol=TESLA&"
    var cancellable: Set<AnyCancellable> = Set()
    var stockViewDispatchGroup = DispatchGroup()

    private var apikey = "00HW87JZWQ30BPUN"

    init() {
        //fetchStockPrice()
    }

    func fetchStockViews() {
        stockViewDispatchGroup.enter()
        fetchStockView("TSLA") { self.stockViewDispatchGroup.leave() }

        stockViewDispatchGroup.enter()
        fetchStockView("BCRX") { self.stockViewDispatchGroup.leave() }

        stockViewDispatchGroup.enter()
        fetchStockView("CRSR") { self.stockViewDispatchGroup.leave() }

        stockViewDispatchGroup.enter()
        fetchStockView("AAPL") { self.stockViewDispatchGroup.leave() }

        stockViewDispatchGroup.enter()
        fetchStockView("ELY") { self.stockViewDispatchGroup.leave() }

        stockViewDispatchGroup.enter()
        fetchStockView("GME") { self.stockViewDispatchGroup.leave() }

        stockViewDispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                print("Done fetching all stocks")
            }
        }
    }


    func fetchStockView(_ symbol: String, completion: @escaping() -> Void) {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: "GLOBAL_QUOTE"),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let requestURL = urlComponents?.url else { completion(); return }

        URLSession.shared.dataTask(with: requestURL) { data,_,_ in
            guard let data = data else { completion(); return }

            let jsonDecoder = JSONDecoder()
            do {
                let stockView = try jsonDecoder.decode([String: StockView].self, from: data).values
                DispatchQueue.main.async {
                    self.stockViews.append(contentsOf: stockView)
                }
            } catch {
                print("Error decoding Stock Global View")
            }
            completion()
        }.resume()
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
