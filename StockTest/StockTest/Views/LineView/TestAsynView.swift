////
////  TestAsynView.swift
////  StockTest
////
////  Created by Lambda_School_Loaner_204 on 2/17/21.
////
//
//import SwiftUI
//
//struct TestAsynView: View {
//    @ObservedObject var viewModel: ArticleViewModel
//
//       var body: some View {
//           switch viewModel.state {
//           case .idle:
//               // Render a clear color and start the loading process
//               // when the view first appears, which should make the
//               // view model transition into its loading state:
//               Color.clear.onAppear(perform: viewModel.load)
//           case .loading:
//               ProgressView()
//           case .failed(let _):
//               EmptyView()
//           case .loaded(let article):
//               ScrollView {
//                   VStack(spacing: 20) {
//                       Text(article).font(.title)
//                   }
//                   .padding()
//               }
//           }
//       }
//}
//
//struct TestAsynView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestAsynView(viewModel: ArticleViewModel(loader: Stocks()))
//    }
//}
