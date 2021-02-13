//
//  StockHome.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI

struct StockHome: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: Stock.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Stock.symbol, ascending: true)],
        animation: .default)
    private var stocks: FetchedResults<Stock>

    var body: some View {
        NavigationView {
            List {
                ForEach(stocks) { stock in
                    ZStack {
                        StockRow(symbol: stock.symbol, name: stock.stockName, price: Float(stock.price), change: stock.change)
//                        NavigationLink(
//                            destination: LineView(stock: stock)) {
//                            EmptyView()
//                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Stocks")
        }
    }
}

struct StockHome_Previews: PreviewProvider {
    static var previews: some View {
        StockHome()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
