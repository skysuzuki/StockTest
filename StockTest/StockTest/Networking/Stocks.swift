//
//  Stocks.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI
import Combine

enum stockFunction: String {
    case intraday = "TIME_SERIES_INTRADAY"
    case daily = "TIME_SERIES_DAILY"
    case Weekly = "TIME_SERIES_WEEKLY"
}

class Stocks: ObservableObject, Identifiable {

    @Published var stockView: StockView?
    @Published var prices = [Double]()
    @Published var currentPrice = "...."
    var urlBase = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=IBM&apikey=00HW87JZWQ30BPUN"
    var baseURL = URL(string: "https://www.alphavantage.co/query?")!
    //https://www.alphavantage.co/query?function=TIME_SERIES_DILY&symbol=TESLA&"
    var cancellable: Set<AnyCancellable> = Set()
    var stockViewDispatchGroup = DispatchGroup()
    var id: String
    private var apikey = "00HW87JZWQ30BPUN"

    init(_ id: String) {
        //fetchStockPrice()
        self.id = id
        fetchStockView(id) {}
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

    
    private func fetchStockView(_ symbol: String, completion: @escaping() -> Void) {

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
                let stockViews = try jsonDecoder.decode([String: StockView].self, from: data)
                DispatchQueue.main.async {
                    print("\(symbol)")
                    self.stockView = stockViews["Global Quote"]
                }
            } catch {
                print("Error decoding Stock Global View")
            }
            completion()
        }.resume()
    }

    func fetchStockPrice(_ symbol: String, _ function: stockFunction) {

        //let url = URL(string: urlBase + apiKey)!

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: function.rawValue),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "interval", value: "5min"),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let requestURL = urlComponents?.url else { return }

        URLSession.shared.dataTaskPublisher(for: requestURL)
            .map { output in
                return output.data
            }
            .decode(type: StocksMinute.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { _ in
                print("completed \(self.id)")
            }, receiveValue: { value in

                var stockPrices = [Double]()

                let orderedDates = value.timeSeriesMinute?.sorted {
                    guard let d1 = $0.key.stringDateMinute, let d2 = $1.key.stringDateMinute else { return false }
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

    func fetchStockPriceDaily(_ symbol: String, _ function: stockFunction, completion: @escaping() -> Void) {

        //let url = URL(string: urlBase + apiKey)!

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: function.rawValue),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let requestURL = urlComponents?.url else { return }

        URLSession.shared.dataTask(with: requestURL) { data,_,_ in
            guard let data = data else { completion(); return }

            let jsonDecoder = JSONDecoder()
            do {
                let stockDaily = try jsonDecoder.decode(StocksDaily.self, from: data)

                var stockPrices = [Double]()

                let orderedDates = stockDaily.timeSeriesDaily?.sorted {
                    guard let d1 = $0.key.stringDateDaily, let d2 = $1.key.stringDateDaily else { return false }
                    return d1 < d2
                }

                guard let stockData = orderedDates else { return }

                for(_, stock) in stockData {
                    if stockPrices.count < 30 {
                        if let stock = Double(stock.close) {
                            if stock > 0.0 {
                                stockPrices.append(stock)
                            }
                        }
                    }
                }

                print(stockPrices)

                DispatchQueue.main.async {
                    self.prices = stockPrices
                    self.currentPrice = stockData.last?.value.close ?? ""
                }
            } catch {
                print("Error decoding Stock Global View")
            }
            completion()
        }.resume()

//        URLSession.shared.dataTaskPublisher(for: requestURL)
//            .map { output in
//                return output.data
//            }
//            .decode(type: StocksDaily.self, decoder: JSONDecoder())
//            .sink(receiveCompletion: { _ in
//                print("completed \(self.id)")
//            }, receiveValue: { value in
//
//                var stockPrices = [Double]()
//
//                let orderedDates = value.timeSeriesDaily?.sorted {
//                    guard let d1 = $0.key.stringDateDaily, let d2 = $1.key.stringDateDaily else { return false }
//                    return d1 < d2
//                }
//
//                guard let stockData = orderedDates else { return }
//
//                for(_, stock) in stockData {
//                    if stockPrices.count < 30 {
//                        if let stock = Double(stock.close) {
//                            if stock > 0.0 {
//                                stockPrices.append(stock)
//                            }
//                        }
//                    }
//                }
//
//                DispatchQueue.main.async {
//                    self.prices = stockPrices
//                    self.currentPrice = stockData.last?.value.close ?? ""
//                }
//            })
//            .store(in: &cancellable)
    }
}
