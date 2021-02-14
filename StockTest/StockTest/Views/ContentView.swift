//
//  ContentView.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/10/21.
//

import SwiftUI
import CoreData
import Combine
import Charts

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selection: Tab = .home

    enum Tab {
        case home
        case search
    }

    @ObservedObject var stockModel = StockListViewModel()
    @ObservedObject var tempStock = Stocks("CRSR")

    init() {
        stockModel.getStockViews()
        //stocks.fetchStockViews()
        //stocks.fetchStockPrice("CRSR", .intraday)
    }

    var body: some View {
        TabView(selection: $selection) {
            StockHome()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)
            SearchHome(stockResults: $tempStock.searchResults,
                       stock: tempStock)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)
        }
    }

    private func addStock() {

        let newStock = Stock(context: viewContext)
        newStock.symbol = "TSLA"

        saveContext()
    }

//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { stocks[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }

    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
