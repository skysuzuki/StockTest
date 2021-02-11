//
//  StockTestApp.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/10/21.
//

import SwiftUI

@main
struct StockTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
