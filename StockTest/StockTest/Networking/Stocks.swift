//
//  Stocks.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI
import Combine
import CoreData
import Charts

enum stockFunction: String {
    case intraday = "TIME_SERIES_INTRADAY"
    case daily = "TIME_SERIES_DAILY"
    case weekly = "TIME_SERIES_WEEKLY"
}

class Stocks: ObservableObject, Identifiable {

    private let moc = PersistenceController.shared.container

    @Published var stockView: StockView?
    @Published var prices = [Double]()
    @Published var pointPrices = [CGPoint]()
    @Published var finishedFetching = false
    @Published private(set) var state = false
    @Published var currentPrice = "...."
    @Published var searchResults = [StockSearchResult]()

    var baseURL = URL(string: "https://www.alphavantage.co/query?")!

    var cancellable: Set<AnyCancellable> = Set()
    var stockViewDispatchGroup = DispatchGroup()
    private var apikey = "C0A7LMCK12GYH6UZ"
    //private var apikey = "00HW87JZWQ30BPUN"

    struct Response<T> {
        let value: T
        let response: URLResponse
    }

    func testLoadPrices(withSymbol: String, completion: @escaping (Result<[ChartDataEntry], Error>) -> Void) {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: stockFunction.intraday.rawValue),
            URLQueryItem(name: "symbol", value: withSymbol),
            URLQueryItem(name: "interval", value: "5min"),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let requestURL = urlComponents?.url else {
            print("Request URL is nil")
            completion(.failure(NSError()))
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError()))
                return
            }

            let jsonDecoder = JSONDecoder()
            do {
                let value = try jsonDecoder.decode(StocksMinute.self, from: data)
                var stockPrices = [Double]()
                var chartData = [ChartDataEntry]()

                let orderedDates = value.timeSeriesMinute?.sorted {
                    guard let d1 = $0.key.stringDateMinute, let d2 = $1.key.stringDateMinute else { return false }
                    return d1 < d2
                }

                guard let stockData = orderedDates else { return }

                self.removePrices(symbol: withSymbol, interval: nil)

                var index: Double = 0
                for(_, stock) in stockData {
                    if let stock = Double(stock.close) {
                        if stock > 0.0 {
                            stockPrices.append(stock)

                            chartData.append(ChartDataEntry(x: index, y: stock))
                            index += 1

                            self.addPrice(with: stock, symbol: withSymbol, interval: nil)
                        }
                    }
                }
                completion(.success(chartData))
            } catch {
                completion(.failure(error))
            }
        }.resume()

    }

    func searchStocks(_ search: String) {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: "SYMBOL_SEARCH"),
            URLQueryItem(name: "keywords", value: search),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let url = urlComponents?.url else { return }
        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = "GET"
        URLSession.shared.dataTaskPublisher(for: requestURL)
            .map { output in
                return output.data
            }
            .decode(type: StockSearch.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { _ in
                print("completed search")
            }, receiveValue: { value in

                DispatchQueue.main.async {
                    self.searchResults = value.bestMatches
                }
            })
            .store(in: &cancellable)


    }


    func networkRun<T: Decodable>(_ request: URLRequest) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in

                let decodedValue = try JSONDecoder().decode([String : T].self, from: result.data)
                let value = decodedValue["Global Quote"]!
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func request(_ symbol: String) -> AnyPublisher<StockView, Error> {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: "GLOBAL_QUOTE"),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let url = urlComponents?.url else { fatalError("Not valid URL") }
        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = "GET"

        return networkRun(requestURL)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    func getStockViews(_ symbol: String) {
        let cancel = request(symbol)
            .mapError({ (error) -> Error in
                print(error)
                return error
            })
            .sink(receiveCompletion: { _ in },
            receiveValue: {
                self.stockView = $0
                do {
                    try self.updateStockViews(with: $0)
                } catch {
                    print("Error updating")
                }
            })
        cancellable.insert(cancel)
    }

    func fetchStockView(_ symbol: String) {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: "GLOBAL_QUOTE"),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let url = urlComponents?.url else { return }
        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = "GET"

        URLSession.shared.dataTaskPublisher(for: requestURL)
            .map { output in
                return output.data
            }
            .decode(type: [String: StockView].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Handle \(error)")
                case .finished:
                    print("completed \(symbol)")
                    break
                }
            }) { value in

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
            }
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

    func addPrice(with price: Double, symbol: String, interval: String?) {
        let stockFetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        stockFetchRequest.predicate = NSPredicate(format: "symbol == %@", symbol)
        let context = moc.newBackgroundContext()
        context.perform {
            do {
                let existingStocks = try context.fetch(stockFetchRequest)
                //guard let stock = existingStocks.first(where: { $0.symbol == symbol }) else { return }

                self.createPrice(with: price, stock: existingStocks[0], interval: interval, context: context)
            } catch {
                print("Error fetching entries for \(symbol): \(error)")
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

    func removePrices(symbol: String, interval: String?) {
        //        let stockFetch: NSFetchRequest<Stock> = Stock.fetchRequest()
        //        stockFetch.predicate = NSPredicate(format: "symbol == %@", symbol)
        var priceInterval = ""
        switch interval {
        case "1W":
            priceInterval = "weekly"
        case "1M":
            priceInterval = "month"
        case "3M":
            priceInterval = "threeMonth"
        case "1Y":
            priceInterval = "year"
        case "5Y":
            priceInterval = "fiveYear"
        default:
            priceInterval = "daily"
        }
        let pricesFetch: NSFetchRequest<Price> = Price.fetchRequest()
        pricesFetch.predicate = NSPredicate(format: "%K == %@", "\(priceInterval).symbol", symbol)
        let context =  PersistenceController.shared.container.viewContext
        context.perform {
            do {
                //let stocks = try context.fetch(stockFetch)
                let prices = try context.fetch(pricesFetch)

                for price in prices {

                    context.delete(price)

                    //                    if price.daily?.symbol == stocks[0].symbol{
                    //                        context.delete(price)
                    //                    }
                }
            } catch {
                print("error removing list")
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

    func createPrice(with stockPrice: Double, stock: Stock, interval: String?, context: NSManagedObjectContext) {
        let price = Price(context: context)
        price.price = stockPrice

        if let inter = interval {
            switch inter {
            case "1W":
                price.weekly = stock
            case "1M":
                price.month = stock
            case "3M":
                price.threeMonth = stock
            case "1Y":
                price.year = stock
            case "5Y":
                price.fiveYear = stock
            default:
                return
            }
        } else {
            price.daily = stock
        }
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

        guard let url = urlComponents?.url else { return }
        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = "GET"

        URLSession.shared.dataTaskPublisher(for: requestURL)
            .map { output in
                return output.data
            }
            .decode(type: StocksMinute.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Handle \(error)")
                case .finished:
                    print("completed \(self.id)")
                    break
                }
            }) { value in

                var stockPrices = [Double]()
                var pointData = [CGPoint]()

                let orderedDates = value.timeSeriesMinute?.sorted {
                    guard let d1 = $0.key.stringDateMinute, let d2 = $1.key.stringDateMinute else { return false }
                    return d1 < d2
                }

                guard let stockData = orderedDates else { return }

                self.removePrices(symbol: symbol, interval: nil)

                var index: Double = 1
                for(_, stock) in stockData {
                    if let stock = Double(stock.close) {
                        if stock > 0.0 {
                            stockPrices.append(stock)

                            pointData.append(CGPoint(x: index, y: stock))
                            index += 1
                            
                            self.addPrice(with: stock, symbol: symbol, interval: nil)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.prices = stockPrices
                    self.pointPrices = pointData
                    self.state = true
                    self.finishedFetching = true
                    print("fetch:\(stockPrices)")
                    self.currentPrice = stockData.last?.value.close ?? ""
                }
            }
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

        guard let url = urlComponents?.url else { return }
        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = "GET"

        URLSession.shared.dataTaskPublisher(for: requestURL)
            .map { output in
                return output.data
            }
            .decode(type: StocksDaily.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Handle \(error)")
                case .finished:
                    print("completed \(self.id)")
                    break
                }
            }) { value in

                guard let stockPrices = self.sortStockByDate(value.timeSeries, symbol: symbol, interval) else { return }

                DispatchQueue.main.async {
                    self.prices = stockPrices
                    //self.currentPrice = stockData.last?.value.close ?? ""
                }
            }
            .store(in: &cancellable)
    }

    func fetchStockPriceYearly(_ symbol: String,_ interval: String) {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: stockFunction.weekly.rawValue),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let url = urlComponents?.url else { return }
        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = "GET"

        URLSession.shared.dataTaskPublisher(for: requestURL)
            .map { output in
                return output.data
            }
            .decode(type: StocksWeekly.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Handle \(error)")
                case .finished:
                    print("completed \(self.id)")
                    break
                }
            }) { value in

                guard let stockPrices = self.sortStockByDate(value.timeSeries, symbol: symbol, interval) else { return }

                DispatchQueue.main.async {
                    self.prices = stockPrices
                    //self.currentPrice = stockData.last?.value.close ?? ""
                }
            }
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
    private func sortStockByDate(_ timeSeries: [String : StockPrice]?, symbol: String, _ interval: String) -> [Double]? {
        let orderedDates = timeSeries?.sorted {
            guard let d1 = $0.key.stringDateDaily, let d2 = $1.key.stringDateDaily else { return false }
            return d1 < d2
        }

        guard let stockData = orderedDates else { return nil }

        let stockCount = self.stockCountForInterval(interval)

        self.removePrices(symbol: symbol, interval: interval)
        
        var stockPrices = [Double]()
        for(_, stock) in stockData {
            if stockPrices.count < stockCount {
                if let stock = Double(stock.close) {
                    if stock > 0.0 {
                        stockPrices.append(stock)
                        self.addPrice(with: stock, symbol: symbol, interval: interval)
                    }
                }
            }
        }
        return stockPrices
    }
}
