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
    case search = "SYMBOL_SEARCH"
    case quote = "GLOBAL_QUOTE"
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

    // Function to fetch Daily prices by 5min interval - does not need interval
    func loadDailyPrices(withSymbol: String, completion: @escaping (Result<[ChartDataEntry], Error>) -> Void) {

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

    // Loads the prices for the week using 60min interval days
    func loadWeeklyPrices(withSymbol: String, completion: @escaping (Result<[ChartDataEntry], Error>) -> Void) {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: stockFunction.intraday.rawValue),
            URLQueryItem(name: "symbol", value: withSymbol),
            URLQueryItem(name: "interval", value: "60min"),
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
                let value = try jsonDecoder.decode(Stocks60Minute.self, from: data)
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

    // Pass in string value to search for a stock.
    func searchStocks(_ search: String) {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: stockFunction.search.rawValue),
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

    // Use of a generic to load stock views.
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

    // Use of a generic to make a request on a stock view
    func request(_ symbol: String) -> AnyPublisher<StockView, Error> {

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: stockFunction.quote.rawValue),
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

    // Used the request function using a symbol to get each stock view
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

    // Updates a stock view based upon the information pulled back from the API
    func updateStockView(stock: Stock, with stockView: StockView) {
        stock.change = Double(stockView.change) ?? 0.00
        stock.currPrice = Double(stockView.price) ?? 0.00
        stock.changePercent = Double(stockView.changePercent) ?? 0.00
    }

    // Uses core data to update each stock with pulled in values
    func updateStockViews(with stockView: StockView) throws {

        let representationBySymbol = [stockView.symbol : stockView]

        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()

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

    // Adds a price to the price core data model
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

    // Clears out all the prices for a given stock and its interval before placing new values in
    func removePrices(symbol: String, interval: String?) {
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
                let prices = try context.fetch(pricesFetch)

                for price in prices {

                    context.delete(price)
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

    // Creates a price object to save to each stocks array of prices based upon what kind of data got back
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
//    func fetchStockPrice(_ symbol: String) {
//
//        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
//        urlComponents?.queryItems = [
//            URLQueryItem(name: "function", value: stockFunction.intraday.rawValue),
//            URLQueryItem(name: "symbol", value: symbol),
//            URLQueryItem(name: "interval", value: "5min"),
//            URLQueryItem(name: "apikey", value: apikey)
//        ]
//
//        guard let url = urlComponents?.url else { return }
//        var requestURL = URLRequest(url: url)
//        requestURL.httpMethod = "GET"
//
//        URLSession.shared.dataTaskPublisher(for: requestURL)
//            .map { output in
//                return output.data
//            }
//            .decode(type: StocksMinute.self, decoder: JSONDecoder())
//            .sink(receiveCompletion: { result in
//                switch result {
//                case .failure(let error):
//                    print("Handle \(error)")
//                case .finished:
//                    print("completed \(self.id)")
//                    break
//                }
//            }) { value in
//
//                var stockPrices = [Double]()
//                var pointData = [CGPoint]()
//
//                let orderedDates = value.timeSeriesMinute?.sorted {
//                    guard let d1 = $0.key.stringDateMinute, let d2 = $1.key.stringDateMinute else { return false }
//                    return d1 < d2
//                }
//
//                guard let stockData = orderedDates else { return }
//
//                self.removePrices(symbol: symbol, interval: nil)
//
//                var index: Double = 1
//                for(_, stock) in stockData {
//                    if let stock = Double(stock.close) {
//                        if stock > 0.0 {
//                            stockPrices.append(stock)
//
//                            pointData.append(CGPoint(x: index, y: stock))
//                            index += 1
//
//                            self.addPrice(with: stock, symbol: symbol, interval: nil)
//                        }
//                    }
//                }
//
//                DispatchQueue.main.async {
//                    self.prices = stockPrices
//                    self.pointPrices = pointData
//                    self.state = true
//                    self.finishedFetching = true
//                    print("fetch:\(stockPrices)")
//                    self.currentPrice = stockData.last?.value.close ?? ""
//                }
//            }
//            .store(in: &cancellable)
//    }

    // Fetch stocks for yearly prices - Use "1M" or "3M" for interval string
    func loadMonthlyPrices(withSymbol: String, withInterval: String, completion: @escaping (Result<[ChartDataEntry], Error>) -> Void) {

        let requestURL = urlRequestForFunction(withSymbol, function: stockFunction.daily)

        URLSession.shared.dataTask(with: requestURL) { data, _, error in
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
                let value = try jsonDecoder.decode(StocksDaily.self, from: data)
                var stockPrices = [Double]()
                var chartData = [ChartDataEntry]()

                let orderedDates = value.timeSeries?.sorted {
                    guard let d1 = $0.key.stringDateDaily, let d2 = $1.key.stringDateDaily else { return false }
                    return d1 < d2
                }

                guard let stockData = orderedDates else { return }

                let stockCount = self.stockCountForInterval(withInterval)

                self.removePrices(symbol: withSymbol, interval: nil)

                var index: Double = 0
                for(_, stock) in stockData {
                    if stockPrices.count < stockCount {
                        if let stock = Double(stock.close) {
                            if stock > 0.0 {
                                stockPrices.append(stock)

                                chartData.append(ChartDataEntry(x: index, y: stock))
                                index += 1

                                self.addPrice(with: stock, symbol: withSymbol, interval: withInterval)
                            }
                        }
                    }
                }
                completion(.success(chartData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Fetch stocks for yearly prices - Use "1Y" or "5Y" for interval string
    func loadYearlyPrices(withSymbol: String, withInterval: String, completion: @escaping (Result<[ChartDataEntry], Error>) -> Void) {

        let requestURL = urlRequestForFunction(withSymbol, function: stockFunction.weekly)

        URLSession.shared.dataTask(with: requestURL) { data, _, error in
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
                let value = try jsonDecoder.decode(StocksWeekly.self, from: data)
                var stockPrices = [Double]()
                var chartData = [ChartDataEntry]()

                let orderedDates = value.timeSeries?.sorted {
                    guard let d1 = $0.key.stringDateDaily, let d2 = $1.key.stringDateDaily else { return false }
                    return d1 < d2
                }

                guard let stockData = orderedDates else { return }

                let stockCount = self.stockCountForInterval(withInterval)

                self.removePrices(symbol: withSymbol, interval: nil)

                var index: Double = 0
                for(_, stock) in stockData {
                    if stockPrices.count < stockCount {
                        if let stock = Double(stock.close) {
                            if stock > 0.0 {
                                stockPrices.append(stock)

                                chartData.append(ChartDataEntry(x: index, y: stock))
                                index += 1

                                self.addPrice(with: stock, symbol: withSymbol, interval: withInterval)
                            }
                        }
                    }
                }
                completion(.success(chartData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: HELPERS
    // Helper to create a request URL for Month/Yearly calls
    func urlRequestForFunction(_ symbol: String, function: stockFunction) -> URLRequest {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "function", value: function.rawValue),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apikey)
        ]

        guard let url = urlComponents?.url else { fatalError("Bad URL Components") }
        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = "GET"
        return requestURL
    }

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
        case "1W":
            return 35
        case "1M":
            return 30
        case "3M":
            return 90
        case "1Y":
            return 52
        case "5Y":
            return 52 * 3
        default:
            return 100
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
