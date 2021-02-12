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

struct StocksMinute: Codable {
    let timeSeriesMinute: [String: StockPrice]?

    private enum CodingKeys: String, CodingKey {
        case timeSeriesMinute = "Time Series (5min)"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        timeSeriesMinute = try (values.decodeIfPresent([String : StockPrice].self, forKey: .timeSeriesMinute))
    }
}

struct StocksDaily: Codable {
    let timeSeries: [String: StockPrice]?

    private enum CodingKeys: String, CodingKey {
        case timeSeries = "Time Series (Daily)"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        timeSeries = try (values.decodeIfPresent([String : StockPrice].self, forKey: .timeSeries))
    }
}

struct StocksWeekly: Codable {
    let timeSeries: [String: StockPrice]?

    private enum CodingKeys: String, CodingKey {
        case timeSeries = "Weekly Time Series"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        timeSeries = try (values.decodeIfPresent([String : StockPrice].self, forKey: .timeSeries))
    }
}
