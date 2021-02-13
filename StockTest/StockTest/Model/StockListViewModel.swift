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

    @Published var stocks = [Stocks]()
    @Published var stockViews = [StockView]()

    init() {
        stocks.append(Stocks("CRSR"))
        stocks.append(Stocks("AAPL"))
        stocks.append(Stocks("BCRX"))
        stocks.append(Stocks("TSLA"))
        stocks.append(Stocks("ELY"))
        stocks.append(Stocks("GME"))
    }

    func getStockViews() {
        for stock in stocks {
            stock.fetchStockView()
        }

    }

}
