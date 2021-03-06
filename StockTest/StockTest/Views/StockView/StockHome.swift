//
//  StockHome.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI


struct StockHome: View {
    @ObservedObject var stockViewModel: StockListViewModel

    @Binding var stocks: [Stock]

    var body: some View {
        NavigationView {
            List {
                ForEach(stocks) { stock in
                    ZStack {
                        NavigationLink(
                            destination:
                                LineView(
                                    stockView: stock.stockView,
                                    stockName: stock.stockName,
                                    chartPrice: String(stock.currPrice),
                                    stockViewModel: stockViewModel)
                        ) {
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
        StockHome(stockViewModel: StockListViewModel(), stocks: .constant([Stock]()))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
