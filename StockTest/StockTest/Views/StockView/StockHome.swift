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

    @ObservedObject var stockController = StockController(context: PersistenceController.shared.container.viewContext)

    var body: some View {
        NavigationView {
            List {
                ForEach(stockController.stocks) { stock in
                    ZStack {
                        NavigationLink(
                            destination: LineView(stock: stock)) {
                            StockRow(symbol: stock.symbol,
                                     stockName: stock.stockName,
                                     currPrice: Float(stock.currPrice),
                                     change: stock.change)
                        }.buttonStyle(PlainButtonStyle())
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
