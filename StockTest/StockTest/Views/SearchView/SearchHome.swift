//
//  SearchHome.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/12/21.
//

import SwiftUI

struct SearchHome: View {

    @State private var searchText: String = ""
    //let stock: Stocks
    @Binding var stockResults: [StockSearch]

    let stock: Stocks

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, stock: stock)
                List {
                    ForEach(stockResults, id: \.self) { stock in
                        SearchRow(symbol: stock.symbol, stockName: stock.name)
                    }
                }
                .listStyle(InsetListStyle())

            }
            .navigationTitle("Search Stocks")
        }
    }
}

struct SearchHome_Previews: PreviewProvider {
    static var previews: some View {
        SearchHome(stockResults: .constant([StockSearch(symbol: "TSLA", name: "TESLA")]), stock: Stocks())
    }
}
