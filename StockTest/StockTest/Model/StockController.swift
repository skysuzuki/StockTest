//
//  StockController.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/13/21.
//

import Foundation
import CoreData

class StockController: NSObject, ObservableObject {
    @Published var stocks = [Stock]()
    private let fetchedResultController: NSFetchedResultsController<Stock> 

    init(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Stock.symbol, ascending: true)]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                             managedObjectContext: context,
                                                             sectionNameKeyPath: nil,
                                                             cacheName: nil)
        super.init()

        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
            stocks = fetchedResultController.fetchedObjects ?? []
        } catch {
            print("Failed to fetch items")
        }
    }

}

extension StockController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let changedStocks = controller.fetchedObjects as? [Stock] else { return }
        stocks = changedStocks
    }
}
