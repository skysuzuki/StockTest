//
//  StockRow.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/11/21.
//

import SwiftUI

struct StockRow: View {

    let stock: Stocks
    let name: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.stockView?.symbol ?? stock.id)
                    .font(.custom("Arial", size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                Text(name)
                    .font(.custom("Arial", size: 18))
                    .foregroundColor(Color.gray)
            }
            Spacer()
            VStack {
                Button(String(format: "$%.2f", Float(stock.stockView?.price ?? "0.00")!)) {}
                    .frame(width: 75, height: 30)
                    .padding(5)
                    .background(Double(stock.stockView?.change ?? "0.00")! > 0.0 ? Color.green : Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct StockRow_Previews: PreviewProvider {
    static var previews: some View {
        StockRow(stock: Stocks("CRSR"), name: "Test")
    }
}
