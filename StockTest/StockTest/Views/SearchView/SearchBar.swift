//
//  SearchBar.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/12/21.
//

import Foundation
import SwiftUI
import Combine
import UIKit

struct SearchBar: UIViewRepresentable {

    @Binding var text: String

    let stock: Stocks

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String

        let stock: Stocks

        init(text: Binding<String>, stock: Stocks) {
            _text = text
            self.stock = stock
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            self.stock.searchStocks(text)
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, stock: stock)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search Stocks"
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
