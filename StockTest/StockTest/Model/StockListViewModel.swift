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

    @Published var stocks = [Stocks]()
    @Published var stockViews = [StockView]()

    init() {
        stocks.append(Stocks("CRSR"))
        stocks.append(Stocks("AAPL"))
        stocks.append(Stocks("BCRX"))
        stocks.append(Stocks("TSLA"))
        stocks.append(Stocks("ELY"))
        stocks.append(Stocks("GME"))

        let isStocksLoaded = UserDefaults.standard.bool(forKey: "isStocksLoaded")
        if (!isStocksLoaded) {
            addStock(symbol: "CRSR")
            addStock(symbol: "AAPL")
            addStock(symbol: "BCRX")
            addStock(symbol: "TSLA")
            addStock(symbol: "ELY")
            addStock(symbol: "GME")
            UserDefaults.standard.set(true, forKey: "isStocksLoaded")
            print("first Load")
        }
    }

    private func addStock(symbol: String) {

        let newStock = Stock(context: moc)
        newStock.symbol = symbol
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
        for stock in stocks {
            stock.fetchStockView()
        }

    }
}
