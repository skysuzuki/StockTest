//
//  SearchHome.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/12/21.
//

import SwiftUI

struct SearchHome: View {

    @ObservedObject var stockNetwork: Stocks

    //@State private var searchText: String = ""

    var stockResults: [StockSearchResult] = []

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $stockNetwork.searchText)
                List {
                    ForEach( stockNetwork.searchResults, id: \.self) { stock in
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
        SearchHome(stockNetwork: Stocks(), stockResults:[StockSearchResult(symbol: "TSLA", name: "TESLA")])
    }
}
