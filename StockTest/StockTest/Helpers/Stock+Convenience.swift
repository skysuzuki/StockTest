//
//  Stock+Convenience.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/18/21.
//

import Foundation

extension Stock {
    var stockView: StockView {
        return StockView(symbol: symbol, price: String(currPrice), change: String(change), changePercent: String(changePercent))
    }
}
