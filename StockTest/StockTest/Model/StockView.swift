//
//  StockView.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import Foundation

struct StockView: Codable {
    let symbol: String
    let price: String
    let change: String
    let changePercent: String

    private enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case price = "05. price"
        case change = "09. change"
        case changePercent = "10. change percent"
    }
}
