//
//  StockHome.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI

struct StockHome: View {

    let stocks: [Stocks]

    var body: some View {
        NavigationView {
            List {
                ForEach(stocks) { stock in
                    if let stockView = stock.stockView {
                        NavigationLink(
                            destination: LineView(stock: stock),
                            label: {
                                StockRow(stock: stockView)
                        })
                    }
                }
            }
            .navigationTitle("Stocks")
        }
    }
}

struct StockHome_Previews: PreviewProvider {
    static var previews: some View {
        StockHome(stocks: [Stocks("CRSR")])
    }
}
