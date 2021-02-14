//
//  Price+CoreDataProperties.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/14/21.
//
//

import Foundation
import CoreData


extension Price {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Price> {
        return NSFetchRequest<Price>(entityName: "Price")
    }

    @NSManaged public var price: Double
    @NSManaged public var daily: Stock?
    @NSManaged public var year: Stock?
    @NSManaged public var weekly: Stock?
    @NSManaged public var month: Stock?
    @NSManaged public var threeMonth: Stock?
    @NSManaged public var fiveYear: Stock?

}

extension Price : Identifiable {

}
