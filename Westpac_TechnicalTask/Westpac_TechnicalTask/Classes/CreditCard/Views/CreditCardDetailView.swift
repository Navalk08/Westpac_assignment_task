//
//  CreditCardDetailView.swift
//  Westpac_TechnicalTask
//
//  Created by Naval on 24/07/24.
//

import SwiftUI

struct CreditCardDetailView: View {
    var creditDetail: CreditCardModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            CreditCardInfoView(creditDetail: creditDetail)
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .navigationBarTitle(CardCardConstant.creditDetailTitle,  displayMode: .inline)
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.blue)
        }
    }
}

struct CreditCardInfoView: View {
    var creditDetail: CreditCardModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(creditDetail.creditCardNumber)
                    .padding(.bottom, 10)
                    .foregroundColor(.white)
                Spacer()
                Image("credit-card")
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
            }
            
            Text("\(CardCardConstant.expDate)  \(creditDetail.creditCardExpiryDate)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            Text(creditDetail.creditCardType)
                .textCase(.uppercase)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}

#Preview {
    // Create CreditCardModel sample instance with dummy data
    let creditDetail = CreditCardModel(
        id: 1,
        uid: "sampleUID123",
        creditCardNumber: "1234 5678 9012 3456",
        creditCardExpiryDate: "12/25",
        creditCardType: "Visa"
    )
    return CreditCardDetailView(creditDetail: creditDetail)
}
