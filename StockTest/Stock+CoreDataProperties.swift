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

    @NSManaged public var symbol: String?

}

extension Stock : Identifiable {

}
