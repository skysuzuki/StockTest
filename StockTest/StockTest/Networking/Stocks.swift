//
//  Stocks.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI
import Combine
import CoreData

enum stockFunction: String {
    case intraday = "TIME_SERIES_INTRADAY"
    case daily = "TIME_SERIES_DAILY"
    case weekly = "TIME_SERIES_WEEKLY"
}

class Stocks: ObservableObject, Identifiable {



    @Published var stockView: StockView?
    @Published var prices = [Double]()
    @Published var currentPrice = "...."
    @Published var searchResults = [StockSearch]()
    var urlBase = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=IBM&apikey=00HW87JZWQ30BPUN"
    var baseURL = URL(string: "https://www.alphavantage.co/query?")!
    //https://www.alphavantage.co/query?function=TIME_SERIES_DILY&symbol=TESLA&"
    var cancellable: Set<AnyCancellable> = Set()
    var stockViewDispatchGroup = DispatchGroup()
    var id: String
    private var apikey = "00HW87JZWQ30BPUN"

    init(_ id: String) {
        self.id = id
    }

    func searchStocks(_ search: String) {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: "SYMBOL_SEARCH"),
            URLQueryItem(name: "keywords", value: search),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let requestURL = urlComponents?.url else { return }

        URLSession.shared.dataTaskPublisher(for: requestURL)
            .map { output in
                return output.data
            }
            .decode(type: [String: [StockSearch]].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { _ in
                print("completed search")
            }, receiveValue: { value in

                guard let searchData = value["bestMatches"] else { return }
                DispatchQueue.main.async {
                    self.searchResults = searchData
                }
            })
            .store(in: &cancellable)


    }

    func fetchStockView() {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: "GLOBAL_QUOTE"),
            URLQueryItem(name: "symbol", value: self.id),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let requestURL = urlComponents?.url else { return }

        URLSession.shared.dataTaskPublisher(for: requestURL)
            .map { output in
                return output.data
            }
            .decode(type: [String: StockView].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { _ in
                print("completed \(self.id)")
            }, receiveValue: { value in

                DispatchQueue.main.async {
                    self.stockView = value["Global Quote"]
                }
            })
            .store(in: &cancellable)
    }

    // Functionc call to fetch stock data for 1 Day and 1 week
    func fetchStockPrice(_ symbol: String) {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: stockFunction.intraday.rawValue),
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


    // Function call to fetch data for 1 month and 3 months
    func fetchStockPriceMonthly(_ symbol: String,_ interval: String) {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: stockFunction.daily.rawValue),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let requestURL = urlComponents?.url else { return }

        URLSession.shared.dataTaskPublisher(for: requestURL)
            .map { output in
                return output.data
            }
            .decode(type: StocksDaily.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { _ in
                print("completed \(self.id)")
            }, receiveValue: { value in

                guard let stockPrices = self.sortStockByDate(value.timeSeries, interval) else { return }

                DispatchQueue.main.async {
                    self.prices = stockPrices
                    //self.currentPrice = stockData.last?.value.close ?? ""
                }
            })
            .store(in: &cancellable)
    }

    func fetchStockPriceYearly(_ symbol: String,_ interval: String) {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: stockFunction.weekly.rawValue),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let requestURL = urlComponents?.url else { return }

        URLSession.shared.dataTaskPublisher(for: requestURL)
            .map { output in
                return output.data
            }
            .decode(type: StocksWeekly.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { _ in
                print("completed \(self.id)")
            }, receiveValue: { value in

                guard let stockPrices = self.sortStockByDate(value.timeSeries, interval) else { return }

                DispatchQueue.main.async {
                    self.prices = stockPrices
                    //self.currentPrice = stockData.last?.value.close ?? ""
                }
            })
            .store(in: &cancellable)

    }

    // MARK: HELPERS
    func getStockFullName(_ symbol: String) -> String {
        switch symbol {
        case "TSLA":
            return "Tesla"
        case "BCRX":
            return "Biocryst Pharm"
        case "CRSR":
            return "Corsair Gaming Inc"
        case "AAPL":
            return "Apple Inc"
        case "ELY":
            return "Callaway Golf Co."
        case "GME":
            return "Gamestop"
        default:
            return "No Name"
        }
    }
    // Returns the amount of prices to be shown on a graph based on interval
    private func stockCountForInterval(_ interval: String) -> Int {
        switch interval {
        case "1M":
            return 30
        case "3M":
            return 90
        case "1Y":
            return 52
        case "3Y":
            return 52 * 3
        default:
            return 0
        }
    }

    // Returns the stock prices sorted by data
    private func sortStockByDate(_ timeSeries: [String : StockPrice]?, _ interval: String) -> [Double]? {
        let orderedDates = timeSeries?.sorted {
            guard let d1 = $0.key.stringDateDaily, let d2 = $1.key.stringDateDaily else { return false }
            return d1 < d2
        }

        guard let stockData = orderedDates else { return nil }

        let stockCount = self.stockCountForInterval(interval)
        
        var stockPrices = [Double]()
        for(_, stock) in stockData {
            if stockPrices.count < stockCount {
                if let stock = Double(stock.close) {
                    if stock > 0.0 {
                        stockPrices.append(stock)
                    }
                }
            }
        }
        print(stockPrices.count)
        return stockPrices
    }
}
