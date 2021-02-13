//
//  StockListItem.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/12/21.
//

import Foundation

struct StockListItem: Identifiable {
    let id: String
    var fullName: String?
    var stockView: StockView?
    let stockPrice = [StockPrice]()

    init(_ id: String) {
        self.id = id
        self.fullName = self.getStockFullName(id)
    }

    private func getStockFullName(_ symbol: String) -> String {
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
}
