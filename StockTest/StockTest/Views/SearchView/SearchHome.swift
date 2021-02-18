//
//  SearchHome.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/12/21.
//

import SwiftUI

struct SearchHome: View {

    @ObservedObject var stockNetwork: Stocks

    @ObservedObject var stockViewModel: StockListViewModel

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $stockNetwork.searchText)
                List {
                    ForEach( stockNetwork.searchResults, id: \.self) { stockResult in
                        ZStack {
                            NavigationLink(
                                destination:
                                    LineView(
                                        stockView: StockView(
                                            symbol: stockResult.symbol,
                                            price: "0.0",
                                            change: "0.0",
                                            changePercent: "0.0"),
                                        stockName: stockResult.name, stockViewModel: stockViewModel))
                                    {
                                        SearchRow(
                                            symbol: stockResult.symbol,
                                            stockName: stockResult.name)
                                    }
                            }
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
        SearchHome(stockNetwork: Stocks(), stockViewModel: StockListViewModel())
    }
}
