//
//  StockListViewModel.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/12/21.
//

import Foundation
import Combine
import SwiftUI
import CoreData
import Charts

class StockListViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case failed(Error)
        case loaded([ChartDataEntry])
    }

    private let moc = PersistenceController.shared.container.viewContext
    
    let defaults = UserDefaults.standard

    @Published var stockNetwork = Stocks()
    @Published private(set) var state = State.idle

    init() {
        // This happens only once on load of APP, loads in the default stocks
        // Sets the user default for is loaded to true after so that it doesn't load again
        let isStocksLoaded = UserDefaults.standard.bool(forKey: "isStocksLoaded")
        if (!isStocksLoaded) {
            addStock(symbol: "CRSR", stockName: "Corsair")
            addStock(symbol: "AAPL", stockName: "Apple")
            addStock(symbol: "BCRX", stockName: "Bio")
            addStock(symbol: "TSLA", stockName: "Tesla")
            addStock(symbol: "ELY", stockName: "Calloway")
            addStock(symbol: "GME", stockName: "GameStop")
            UserDefaults.standard.set(true, forKey: "isStocksLoaded")
            print("first Load")
        }
    }

    private func addStock(symbol: String, stockName: String) {

        let newStock = Stock(context: moc)
        newStock.symbol = symbol
        newStock.stockName = stockName
        saveContext()
    }

    private func saveContext() {
        do {
            try moc.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }

    func getStockViews() {
        for symbol in StockSymbol.allCases {
            stockNetwork.getStockViews(symbol.rawValue)
        }
    }

    func loadStockPrices(symbol: String) {
        stockNetwork.loadDailyPrices(withSymbol: symbol) { [weak self] result in
            switch result {
            case .success(let chartData):
                DispatchQueue.main.async {
                    self?.state = .loaded(chartData)
                }
            case .failure(let error):
                self?.state = .failed(error)
            }
        }
    }

    func loadStockWeeklyPrices(symbol: String) {
        stockNetwork.loadWeeklyPrices(withSymbol: symbol) { [weak self] result in
            switch result {
            case .success(let chartData):
                DispatchQueue.main.async {
                    self?.state = .loaded(chartData)
                }
            case .failure(let error):
                self?.state = .failed(error)
            }
        }
    }

    func loadMonthlyStockPrices(symbol: String, interval: String) {
        stockNetwork.loadMonthlyPrices(withSymbol: symbol, withInterval: interval) { [weak self] result in
            switch result {
            case .success(let chartData):
                DispatchQueue.main.async {
                    self?.state = .loaded(chartData)
                }
            case .failure(let error):
                self?.state = .failed(error)
            }
        }
    }

    func loadYearlyStockPrices(symbol: String, interval: String) {
        stockNetwork.loadYearlyPrices(withSymbol: symbol, withInterval: interval) { [weak self] result in
            switch result {
            case .success(let chartData):
                DispatchQueue.main.async {
                    self?.state = .loaded(chartData)
                }
            case .failure(let error):
                self?.state = .failed(error)
            }
        }
    }

    func getStockPrices(_ symbol: String, interval: String) -> [ChartDataEntry] {
        var chartData = [ChartDataEntry]()
        let pricesFetch: NSFetchRequest<Price> = Price.fetchRequest()
        pricesFetch.predicate = NSPredicate(format: "%K == %@", "\(interval).symbol", symbol)
        let context =  PersistenceController.shared.container.viewContext
        context.performAndWait {
            do {
                //let stocks = try context.fetch(stockFetch)
                let prices = try context.fetch(pricesFetch)
                var index: Double = 0
                for price in prices {
                    chartData.append(ChartDataEntry(x: index, y: price.price))
                    index += 1
                }

            } catch {
                print("Error ")
            }
        }
        return chartData
    }
}
