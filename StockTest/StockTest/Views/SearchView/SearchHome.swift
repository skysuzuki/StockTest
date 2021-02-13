//
//  SearchHome.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/12/21.
//

import SwiftUI

struct SearchHome: View {

    @Binding var searchText: String
    
    var body: some View {
        VStack{
            SearchBarView(text: $searchText)
                
        }
            //List(
    }
}

struct SearchHome_Previews: PreviewProvider {
    static var previews: some View {
        SearchHome(searchText: .constant("Search"))
    }
}
