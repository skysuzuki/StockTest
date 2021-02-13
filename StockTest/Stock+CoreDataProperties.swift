//
//  Stock+CoreDataProperties.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/13/21.
//
//

import Foundation
import CoreData


extension Stock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stock> {
        return NSFetchRequest<Stock>(entityName: "Stock")
    }

    @NSManaged public var symbol: String
    @NSManaged public var stockName: String
    @NSManaged public var price: Double
    @NSManaged public var change: Double
    @NSManaged public var changePercent: Double
    @NSManaged public var prices: NSSet?

}

// MARK: Generated accessors for prices
extension Stock {

    @objc(addPricesObject:)
    @NSManaged public func addToPrices(_ value: Prices)

    @objc(removePricesObject:)
    @NSManaged public func removeFromPrices(_ value: Prices)

    @objc(addPrices:)
    @NSManaged public func addToPrices(_ values: NSSet)

    @objc(removePrices:)
    @NSManaged public func removeFromPrices(_ values: NSSet)

}

extension Stock : Identifiable {

}
