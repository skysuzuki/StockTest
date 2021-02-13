//
//  Prices+CoreDataProperties.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/13/21.
//
//

import Foundation
import CoreData


extension Prices {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Prices> {
        return NSFetchRequest<Prices>(entityName: "Prices")
    }

    @NSManaged public var open: Double
    @NSManaged public var stock: Stock?

}

extension Prices : Identifiable {

}
