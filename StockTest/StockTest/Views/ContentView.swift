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
    @State private var showSplash = true

    enum Tab {
        case home
        case search
    }

    @ObservedObject var stockController = StockController(context: PersistenceController.shared.container.viewContext)
    @ObservedObject var stockModel = StockListViewModel()

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                StockHome(stockViewModel: stockModel, stocks: $stockController.stocks)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(Tab.home)
                SearchHome(stockResults: $stockModel.stockNetwork.searchResults,
                           stock: stockModel.stockNetwork)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(Tab.search)
            }
            .edgesIgnoringSafeArea(.all)
            SplashScreen()
                .opacity(showSplash ? 1 : 0)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        SplashScreen.shouldAnimate = false
                        withAnimation() {
                            self.showSplash = false
                        }
                    }
                }
        }
        .onAppear {
            stockModel.getStockViews()
        }
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
