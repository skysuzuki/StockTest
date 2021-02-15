//
//  StockListViewModel.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/12/21.
//

import Foundation
import Combine
import SwiftUI

class StockListViewModel: ObservableObject {

    private let moc = PersistenceController.shared.container.viewContext
    let defaults = UserDefaults.standard

    @Published var stockNetwork = Stocks()
    @Published var stockViews = [StockView]()

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
            stockNetwork.fetchStockView(symbol.rawValue)
        }
    }
}
