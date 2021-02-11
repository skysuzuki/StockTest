//
//  StockRow.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI

struct StockRow: View {
    let stock: StockView

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.symbol)
                    .font(.custom("Arial", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                Text(stock.description)
                    .font(.custom("Arial", size: 18))
                    .foregroundColor(Color.gray)
            }
            Spacer()
            VStack {
                Text(String(format: "%.2f", stock.price))
                    .foregroundColor(Color.black)
                    .font(.custom("Arial", size: 22))
                Button(stock.change) {

                }
                .frame(width: 75)
                .padding(5)
                .background(Color.red)
                .foregroundColor(Color.white)
                .cornerRadius(6)
            }
        }
    }
}

struct StockRow_Previews: PreviewProvider {
    static var previews: some View {
        let stock = StockView(symbol: "BCRX", price: 56.89, description: "Biocryst", change: "-0.35")
        StockRow(stock: stock)
    }
}
