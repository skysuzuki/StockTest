//
//  StockList.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI

struct StockList: View {

    let stocks: [StockView]
    
    var body: some View {
        List(self.stocks, id: \.symbol) { stock in
            StockRow(stock: stock)
        }
    }
}

struct StockList_Previews: PreviewProvider {
    static var previews: some View {
        let stocks = [
        StockView(symbol: "BCRX", price: 56.89, description: "Biocryst", change: "-0.35"),
        StockView(symbol: "CRSR", price: 59.89, description: "Corsair", change: "-0.42")
        ]

        StockList(stocks: stocks)
    }
}


