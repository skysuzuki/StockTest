////
////  ArticleViewModel.swift
////  StockTest
////
////  Created by Lambda_School_Loaner_204 on 2/17/21.
////
//
//import Foundation
//import SwiftUI
//
//class ArticleViewModel: ObservableObject {
//    enum State {
//        case idle
//        case loading
//        case failed(Error)
//        case loaded([CGPoint])
//    }
//
//    @Published private(set) var state = State.idle
//
//    private let symbol: String
//    private let loader: Stocks
//
//    init(loader: Stocks) {
//        self.loader = loader
//        self.symbol = "2"
//    }
//
//    func load() {
//        state = .loading
//
//        loader.testLoadPrices(withSymbol: symbol) { [weak self] result in
//            switch result {
//            case .success(let points):
//                self?.state = .loaded(points)
//            case .failure(let error):
//                self?.state = .failed(error)
//            }
//        }
//    }
//}
