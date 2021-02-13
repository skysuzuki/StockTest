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
                    ZStack {
                        StockRow(stock: stock, name: stock.getStockFullName(stock.id))
                        NavigationLink(
                            destination: LineView(stock: stock)) {
                            EmptyView()
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
        StockHome(stocks: [Stocks("CRSR")])
    }
}
