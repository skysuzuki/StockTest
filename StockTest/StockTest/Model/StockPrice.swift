//
//  StockPrice.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import Foundation

struct StockPrice: Codable {
    let open: String
    let high: String
    let low: String
    let close: String

    private enum CodingKeys: String, CodingKey {

        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
    }
}

struct StocksDaily: Codable {
    let timeSeriesDaily: [String: StockPrice]?

    private enum CodingKeys: String, CodingKey {
        case timeSeriesDaily = "Time Series (5min)"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        timeSeriesDaily = try (values.decodeIfPresent([String : StockPrice].self, forKey: .timeSeriesDaily))
    }
}
