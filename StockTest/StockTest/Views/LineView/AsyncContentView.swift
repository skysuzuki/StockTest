//
//  AsyncContentView.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/17/21.
//

import SwiftUI

enum LoadingState<Value> {
    case idle
    case loading
    case failed(Error)
    case loaded(Value)
}

protocol LoadableObject: ObservableObject {
    associatedtype Output
    var state: LoadingState<Output> { get }
    func load()
}

struct AsyncContentView<Source: LoadableObject, Content: View>: View {
    @ObservedObject var source: Source
    var content: (Source.Output) -> Content

    init(source: Source,
         @ViewBuilder content: @escaping (Source.Output) -> Content) {
        self.source = source
        self.content = content
    }

    var body: some View {
        switch source.state {
        case .idle:
            Color.clear.onAppear(perform: source.load)
        case .loading:
            ProgressView()
        case .failed(let _):
            EmptyView()
        case .loaded(let output):
            content(output)
        }
    }
}

//struct AsyncContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AsyncContentView<Sparkline>(content: )
//    }
//}
