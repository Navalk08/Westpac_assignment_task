//
//  ContentView.swift
//  Westpac_TechnicalTask
//
//  Created by Naval on 24/07/24.
//

import SwiftUI

struct CreditCardListView: View {
    @ObservedObject var viewModel: CreditCardViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading && viewModel.creditCardList.isEmpty {
                    ProgressView(CardCardConstant.loading)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    //credit list view
                    List(viewModel.creditCardList, id: \.id) { data in
                        CardView(viewModel: viewModel, creditCardDetail: data)
                            .listRowSeparator(.hidden) // hide list separtor line
                            .onAppear {
                                if data == viewModel.creditCardList.last {
                                    viewModel.loadCreditCardList()
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitle(viewModel.navigationTitle, displayMode: .inline)
            .toolbar {
                //right toolbar item
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: BookMarkedListView(viewModel: viewModel)) {
                        Text(CardCardConstant.bookMarks)
                    }
                }
            }
        }
        .onAppear {
            //fetch credit list data
            if viewModel.creditCardList.isEmpty {
                viewModel.loadCreditCardList()
            }
        }
        .alert(item: $viewModel.errorMessage) { errorMessage in
            //show alert in case getting error from api side
            Alert(
                title: Text(CardCardConstant.error),
                message: Text(errorMessage.message),
                dismissButton: .default(Text(CardCardConstant.ok))
            )
        }
    }
}

//MARK: cardView 
struct CardView: View {
    var viewModel: CreditCardViewModel
    var creditCardDetail: CreditCardModel
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(creditCardDetail.creditCardNumber)
                    .font(.headline)
                    .padding(.bottom, 2)
                
                Text("\(CardCardConstant.expDate) \(viewModel.formattedDate(from: creditCardDetail.creditCardExpiryDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
                
                Text(creditCardDetail.creditCardType)
                    .textCase(.uppercase)
                    .font(.system(size: 14))
            }
            
            Spacer()
            
            //bookmark button
            Button(action: {
                //action to be performed save/unsave bookmarks
                viewModel.toggleBookmark(card: creditCardDetail)
            }) {
                Image(systemName: creditCardDetail.isBookMark ? "star.fill" : "star")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.yellow)
            }
            .buttonStyle(PlainButtonStyle())
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .background(
            // link credit deatil view
            NavigationLink("", destination: CreditCardDetailView(creditDetail: creditCardDetail))
                .opacity(0)
                .buttonStyle(PlainButtonStyle())
        )
    }
}

#Preview {
    CreditCardListView(viewModel: CreditCardViewModel())
}
