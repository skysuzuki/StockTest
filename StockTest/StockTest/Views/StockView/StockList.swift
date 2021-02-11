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
        let stocks = Stocks()

        StockList(stocks: stocks.stockViews)
    }
}


