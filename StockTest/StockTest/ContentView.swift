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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var selection: Tab = .home

    enum Tab {
        case home
        case search
    }

    @ObservedObject var stockModel = StockListViewModel()

//    @ObservedObject var crsrStock = Stocks("CRSR")
//    @ObservedObject var applStock = Stocks("AAPL")
//    @ObservedObject var bcrxStock = Stocks("BCRX")
//    @ObservedObject var tslaStock = Stocks("TSLA")
//    @ObservedObject var elyStock = Stocks("ELY")
//    @ObservedObject var gmeStock = Stocks("GME")

    init() {
        stockModel.getStockViews()
        //stocks.fetchStockViews()
        //stocks.fetchStockPrice("CRSR", .intraday)
    }

    var body: some View {
        TabView(selection: $selection) {
            StockHome(stocks: stockModel.stocks)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)
            SearchHome(searchText: .constant(""))
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)
//            CategoryHome()
//                .tabItem {
//                    Label("Featured", systemImage: "star")
//                }
//                .tag(Tab.featured)
//
//            LandmarkList()
//                .tabItem {
//                    Label("List", systemImage: "list.bullet")
//                }
//                .tag(Tab.list)
        }


            //        List {
            //            ForEach(items) { item in
            //                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
            //            }
            //            .onDelete(perform: deleteItems)
            //        }
            //        .toolbar {
            //            #if os(iOS)
            //            EditButton()
            //            #endif
            //
            //            Button(action: addItem) {
            //                Label("Add Item", systemImage: "plus")
            //            }
            //        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
