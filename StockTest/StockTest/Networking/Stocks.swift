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

    private let moc = PersistenceController.shared.container

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
                    if let stock = value["Global Quote"] {
                        self.stockView = stock
                        do {
                            try self.updateStockViews(with: stock)
                        } catch {
                            print("Error updating")
                        }
                    }
                }
            })
            .store(in: &cancellable)
    }

    func updateStockView(stock: Stock, with stockView: StockView) {
        stock.change = Double(stockView.change) ?? 0.00
        stock.currPrice = Double(stockView.price) ?? 0.00
        stock.changePercent = Double(stockView.changePercent) ?? 0.00
    }

    func updateStockViews(with stockView: StockView) throws {

        let representationBySymbol = [stockView.symbol : stockView]

        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        //fetchRequest.predicate = NSPredicate(format: "symbol IN %@", stockView.symbol)

        let context = moc.newBackgroundContext()
        context.perform {
            do {
                let existingStocks = try context.fetch(fetchRequest)

                for stock in existingStocks {
                    guard let stockView = representationBySymbol[stock.symbol] else { continue }

                    self.updateStockView(stock: stock, with: stockView)
                }
            } catch {
                print("Error fetching entries for UUIDs: \(error)")
            }
        }

        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("error saving")
            }
        }
    }

    func updateStockPrices(stock: Stock, with prices: [Price]) {
        for price in prices {
            stock.addToPrice(price)
        }
    }

    func addPrice(with price: Double, symbol: String) {
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        let context = moc.newBackgroundContext()
        context.perform {
            do {
                let existingStocks = try context.fetch(fetchRequest)
                guard let stock = existingStocks.first(where: { $0.symbol == symbol }) else { return }

                self.createPrice(with: price, stock: stock, context: context)
            } catch {
                print("Error fetching entries for UUIDs: \(error)")
            }
        }

        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("error saving")
            }
        }
    }

    func updatePrices() {
//        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
//        let priceFetch: NSFetchRequest<Price> = Price.fetchRequest()
//        //fetchRequest.predicate = NSPredicate(format: "symbol IN %@", stockView.symbol)
//
//        let context = moc.newBackgroundContext()
//        context.perform {
//            do {
//                let existingStocks = try context.fetch(fetchRequest)
//                let existingPrices = try context.fetch(priceFetch)
//                guard let stock = existingStocks.first(where: { $0.symbol == self.id }) else { return }
//
//                for price in existingPrices {
//                    if price.stock == stock {
//                        print(price.price, price.stock?.symbol)
//                    }
//                }
//            } catch {
//                print("Error fetching entries for UUIDs: \(error)")
//            }
//        }
//
//        context.performAndWait {
//            do {
//                try context.save()
//            } catch {
//                print("error saving")
//            }
//        }

        let context =  PersistenceController.shared.container.viewContext
        context.performAndWait {
            do {
                let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
                let priceFetch: NSFetchRequest<Price> = Price.fetchRequest()

                let existingStocks = try context.fetch(fetchRequest)
                let existingPrices = try context.fetch(priceFetch)
                guard let stock = existingStocks.first(where: { $0.symbol == self.id }) else { return }

                stock.prices = stock.prices?.addingObjects(from: existingPrices) as NSSet?
//                for price in existingPrices {
//                    if price.stock == stock {
//                        stock.mutableSetValue(forKey: "prices").add(price)
//                        //stock.addToPrice(price)
//                        //stock.objectWillChange.send()
//                        print(price.price, price.stock?.symbol)
//                    }
//                }
            } catch {
                print(error)
            }
        }
    }

    func createPrice(with stockPrice: Double, stock: Stock, context: NSManagedObjectContext) {
        let price = Price(context: context)
        price.price = stockPrice
        price.stock = stock
        stock.mutableSetValue(forKey: "prices").add(price)
        do {
            try context.save()
        } catch {
            print("Error saving object \(error)")
        }
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

                            self.addPrice(with: stock, symbol: symbol)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.prices = stockPrices
                    //self.updatePrices()
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
