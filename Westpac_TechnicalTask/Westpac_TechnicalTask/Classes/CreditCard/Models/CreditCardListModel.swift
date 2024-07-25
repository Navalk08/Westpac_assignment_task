//
//  CreditCardListModel.swift
//  Westpac_TechnicalTask
//
//  Created by Naval on 24/07/24.
//

import Foundation

struct CreditCardModel: Identifiable, Codable, Hashable {
    let id: Int
    let uid: String
    let creditCardNumber: String
    let creditCardExpiryDate: String
    let creditCardType: String
    var isBookMark: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case creditCardNumber = "credit_card_number"
        case creditCardExpiryDate = "credit_card_expiry_date"
        case creditCardType = "credit_card_type"
    }

}
