//
//  BookMarkedListView.swift
//  Westpac_TechnicalTask
//
//  Created by Naval on 24/07/24.
//

import SwiftUI

struct BookMarkedListView: View {
    @ObservedObject var viewModel: CreditCardViewModel
    
    var body: some View {
        VStack {
            if viewModel.bookMarkedList.isEmpty {
                //empty list text
                Text(CardCardConstant.noBookMarkedData)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                //bookmarked list view
                List(viewModel.bookMarkedList, id: \.id) { data in
                    CardView(viewModel: viewModel, creditCardDetail: data)
                        .listRowSeparator(.hidden) // hide list separtor line
                        .disabled(true) // disable interaction of entire view
                }
                .listStyle(.plain)
            }
        }
    }
    
}

#Preview {
    BookMarkedListView(viewModel: CreditCardViewModel())
}
