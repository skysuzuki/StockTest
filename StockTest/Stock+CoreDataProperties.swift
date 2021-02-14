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
    @NSManaged public var currPrice: Double
    @NSManaged public var change: Double
    @NSManaged public var changePercent: Double
    @NSManaged public var prices: NSSet?

}

// MARK: Generated accessors for price
extension Stock {

    @objc(addPriceObject:)
    @NSManaged public func addToPrice(_ value: Price)

    @objc(removePriceObject:)
    @NSManaged public func removeFromPrice(_ value: Price)

    @objc(addPrice:)
    @NSManaged public func addToPrice(_ values: NSSet)

    @objc(removePrice:)
    @NSManaged public func removeFromPrice(_ values: NSSet)

}

extension Stock : Identifiable {

}
