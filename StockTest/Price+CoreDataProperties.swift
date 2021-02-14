//
//  Price+CoreDataProperties.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/13/21.
//
//

import Foundation
import CoreData


extension Price {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Price> {
        return NSFetchRequest<Price>(entityName: "Price")
    }

    @NSManaged public var price: Double
    @NSManaged public var stock: Stock?

}

extension Price : Identifiable {

}
