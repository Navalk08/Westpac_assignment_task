//
//  CreditCardViewModel.swift
//  Westpac_TechnicalTask
//
//  Created by Naval on 24/07/24.
//

import Foundation
import Combine

class CreditCardViewModel: ObservableObject {
    // Credit card View Properties
    @Published var creditCardList: [CreditCardModel] = []
    @Published var errorMessage: ErrorMessage?
    @Published var isLoading: Bool = false
    @Published var page = 10
    var navigationTitle = CardCardConstant.navigationTitle
    
    private var uniqueIDs = Set<Int>()
    private var bookmarkedCardIds: Set<Int> = []
    
    var bookMarkedList: [CreditCardModel] {
        //filter bookmarked list
        let result = creditCardList.filter { $0.isBookMark }
        return result
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
    }
    
    //MARK: credit card list api
    func loadCreditCardList() {
        guard let url = URL(string: APIAddress.creditListApiUrl + "\(page)") else {
            self.errorMessage = ErrorMessage(message: APIError.unknown(URLError(.badURL)).errorDescription ?? CardCardConstant.UnknownError)
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        
        print("Page: \(page)")
        isLoading = true
        RestClient.shared.apiRequest(request)
            .receive(on: DispatchQueue.main) // ensure updates are received on the main thread
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    //handle the error without showing an alert in case multiple try
                    if let apiError = error as? APIError, apiError == .rateLimited {
                        print(CardCardConstant.reTry)
                    } else {
                        //handel error cases
                        self.handleError(error)
                    }
                }
            }, receiveValue: { [weak self] (data: [CreditCardModel]) in
                //first sort list by credit card type
                DispatchQueue.main.async {
                    self?.sortCreditListWithType(creditList: data)
                    self?.page += 1
                }
            })
            .store(in: &cancellables)
    }
    
    //handle error cases 
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            self.errorMessage = ErrorMessage(message: apiError.errorDescription ?? CardCardConstant.UnknownError)
        } else {
            self.errorMessage = ErrorMessage(message: APIError.unknown(error).errorDescription ?? CardCardConstant.UnknownError)
        }
    }
    
    //Sort list by type
    func sortCreditListWithType(creditList: [CreditCardModel]) {
        //add new data to the list and ensure uniqueness
        let newUniqueData = creditList.filter { uniqueIDs.insert($0.id).inserted }
        creditCardList += newUniqueData
        
        // Sort the entire list with type
        creditCardList.sort { $0.creditCardType < $1.creditCardType }
    }
    
    //bookmark list
    func toggleBookmark(card: CreditCardModel) {
        //toggle the bookmark status
        if bookmarkedCardIds.contains(card.id) {
            bookmarkedCardIds.remove(card.id)
        } else {
            bookmarkedCardIds.insert(card.id)
        }
        
        //update the creditCardList to reflect the bookmark changes
        creditCardList = creditCardList.map { card in
            var updatedCard = card
            updatedCard.isBookMark = bookmarkedCardIds.contains(card.id)
            return updatedCard
        }
    }
    
    //MARK: change date formate
    func formattedDate(from dateString: String) -> String {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "MM/yy"
        
        if let date = inputDateFormatter.date(from: dateString) {
            return outputDateFormatter.string(from: date)
        } else {
            return "Invalid Date"
        }
    }
    
}
