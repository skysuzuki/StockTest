//
//  StockRow.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI

struct StockRow: View {

    let symbol: String
    let stockName: String
    let currPrice: Float
    let change: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(symbol)
                    .font(.custom("Arial", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                Text(stockName)
                    .font(.custom("Arial", size: 18))
                    .foregroundColor(Color.gray)
            }
            Spacer()
            VStack {
                Button(String(format: "$%.2f", currPrice)) {}
                    .frame(width: 75, height: 30)
                    .padding(5)
                    .background(change > 0.0 ? Color.green : Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct StockRow_Previews: PreviewProvider {
    static var previews: some View {
        StockRow(symbol: "CRSR", stockName: "Corsair", currPrice: 0.5, change: 0.5)
                    
    }
}
