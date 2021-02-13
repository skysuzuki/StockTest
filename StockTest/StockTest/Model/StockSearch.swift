//
//  StockSearch.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/12/21.
//

import Foundation

struct StockSearch: Codable {
    let symbol: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
    }
}
