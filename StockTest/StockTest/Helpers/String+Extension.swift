//
//  String+Extension.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import Foundation

extension String {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    var stringDateDaily: Date? {
        return String.shortDate.date(from: self)
    }

    var stringDateMinute: Date? {
        return String.longDate.date(from: self)
    }
}
