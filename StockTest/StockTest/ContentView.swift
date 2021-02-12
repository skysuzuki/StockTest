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

    @ObservedObject var stocks = Stocks()

    init() {
        stocks.fetchStockViews()
        //stocks.fetchStockPrice()
    }

    var body: some View {

        let stockViews = stocks.stockViews

        VStack {
            
        }

        NavigationView{
//
            //        LineView(data: stocks.prices, title: "IBM", legend: "Full Screen")
            //            .padding()
            //            LineView(data: stocks.prices, title: "IBM", price: "\(stocks.currentPrice) INR")
            //                    .padding()
            //LineView(data: [8,23,54,32], title: "TESLA")
            StockList(stocks: stockViews)

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
            .navigationBarTitle("Stocks")
        }
        .edgesIgnoringSafeArea(Edge.Set(.bottom))
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
