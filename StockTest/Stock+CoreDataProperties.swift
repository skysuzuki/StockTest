//
//  Stock+CoreDataProperties.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/14/21.
//
//

import Foundation
import CoreData


extension Stock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stock> {
        return NSFetchRequest<Stock>(entityName: "Stock")
    }

    @NSManaged public var change: Double
    @NSManaged public var changePercent: Double
    @NSManaged public var currPrice: Double
    @NSManaged public var stockName: String
    @NSManaged public var symbol: String
    @NSManaged public var dailyPrices: NSOrderedSet?
    @NSManaged public var weekPrices: NSOrderedSet?
    @NSManaged public var oneMPrices: NSOrderedSet?
    @NSManaged public var threeMPrices: NSOrderedSet?
    @NSManaged public var oneYPrices: NSOrderedSet?
    @NSManaged public var fiveYPrices: Price?

}

// MARK: Generated accessors for dailyPrices
extension Stock {

    @objc(insertObject:inDailyPricesAtIndex:)
    @NSManaged public func insertIntoDailyPrices(_ value: Price, at idx: Int)

    @objc(removeObjectFromDailyPricesAtIndex:)
    @NSManaged public func removeFromDailyPrices(at idx: Int)

    @objc(insertDailyPrices:atIndexes:)
    @NSManaged public func insertIntoDailyPrices(_ values: [Price], at indexes: NSIndexSet)

    @objc(removeDailyPricesAtIndexes:)
    @NSManaged public func removeFromDailyPrices(at indexes: NSIndexSet)

    @objc(replaceObjectInDailyPricesAtIndex:withObject:)
    @NSManaged public func replaceDailyPrices(at idx: Int, with value: Price)

    @objc(replaceDailyPricesAtIndexes:withDailyPrices:)
    @NSManaged public func replaceDailyPrices(at indexes: NSIndexSet, with values: [Price])

    @objc(addDailyPricesObject:)
    @NSManaged public func addToDailyPrices(_ value: Price)

    @objc(removeDailyPricesObject:)
    @NSManaged public func removeFromDailyPrices(_ value: Price)

    @objc(addDailyPrices:)
    @NSManaged public func addToDailyPrices(_ values: NSOrderedSet)

    @objc(removeDailyPrices:)
    @NSManaged public func removeFromDailyPrices(_ values: NSOrderedSet)

}

// MARK: Generated accessors for weekPrices
extension Stock {

    @objc(addWeekPricesObject:)
    @NSManaged public func addToWeekPrices(_ value: Price)

    @objc(removeWeekPricesObject:)
    @NSManaged public func removeFromWeekPrices(_ value: Price)

    @objc(addWeekPrices:)
    @NSManaged public func addToWeekPrices(_ values: NSSet)

    @objc(removeWeekPrices:)
    @NSManaged public func removeFromWeekPrices(_ values: NSSet)

}

// MARK: Generated accessors for oneMPrices
extension Stock {

    @objc(addOneMPricesObject:)
    @NSManaged public func addToOneMPrices(_ value: Price)

    @objc(removeOneMPricesObject:)
    @NSManaged public func removeFromOneMPrices(_ value: Price)

    @objc(addOneMPrices:)
    @NSManaged public func addToOneMPrices(_ values: NSSet)

    @objc(removeOneMPrices:)
    @NSManaged public func removeFromOneMPrices(_ values: NSSet)

}

// MARK: Generated accessors for threeMPrices
extension Stock {

    @objc(addThreeMPricesObject:)
    @NSManaged public func addToThreeMPrices(_ value: Price)

    @objc(removeThreeMPricesObject:)
    @NSManaged public func removeFromThreeMPrices(_ value: Price)

    @objc(addThreeMPrices:)
    @NSManaged public func addToThreeMPrices(_ values: NSSet)

    @objc(removeThreeMPrices:)
    @NSManaged public func removeFromThreeMPrices(_ values: NSSet)

}

// MARK: Generated accessors for oneYPrices
extension Stock {

    @objc(addOneYPricesObject:)
    @NSManaged public func addToOneYPrices(_ value: Price)

    @objc(removeOneYPricesObject:)
    @NSManaged public func removeFromOneYPrices(_ value: Price)

    @objc(addOneYPrices:)
    @NSManaged public func addToOneYPrices(_ values: NSSet)

    @objc(removeOneYPrices:)
    @NSManaged public func removeFromOneYPrices(_ values: NSSet)

}

extension Stock : Identifiable {

}
