//
//  SearchRow.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/14/21.
//

import SwiftUI

struct SearchRow: View {
    let symbol: String
    let stockName: String

    var body: some View {
        HStack {
            Text(symbol)
                .font(.custom("Arial", size: 20))
                .bold()
                .background(Color(UIColor.systemBackground))
            Spacer()
            Text(stockName)
                .font(.custom("Arial", size: 18))
                .foregroundColor(Color.gray)
        }
    }
}

struct SearchRow_Previews: PreviewProvider {
    static var previews: some View {
        SearchRow(symbol: "CRSR", stockName: "Corsair")
    }
}
