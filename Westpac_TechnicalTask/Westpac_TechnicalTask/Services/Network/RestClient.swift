//
//  RestClient.swift
//  Westpac_TechnicalTask
//
//  Created by Naval on 24/07/24.
//

import Foundation
import Network
import Combine
import SwiftUI

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

enum APIError: Error, Equatable {
    case noInternetConnection
    case badResponse(statusCode: Int)
    case decodingError
    case rateLimited
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection."
        case .badResponse(let statusCode):
            return "Server returned status code \(statusCode)."
        case .decodingError:
            return "Failed to decode the response."
        case .rateLimited:
            return "Rate limit exceeded. Please try again later."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.noInternetConnection, .noInternetConnection):
            return true
        case (.decodingError, .decodingError):
            return true
        case (.rateLimited, .rateLimited):
            return true
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.badResponse(let lhsStatusCode), .badResponse(let rhsStatusCode)):
            return lhsStatusCode == rhsStatusCode
        default:
            return false
        }
    }
}

class RestClient {
    static let shared = RestClient()
    private var session: URLSession
    
    private init() {
        self.session = URLSession(configuration: .default)
    }
    
    func apiRequest<T: Decodable>(_ request: URLRequest, retryAttempts: Int = 3, retryDelay: TimeInterval = 1.0) -> AnyPublisher<T, Error> {
        guard Reachability().isConnectedToNetwork() else {
            return Fail(error: APIError.noInternetConnection)
                .eraseToAnyPublisher()
        }
        
        return performRequest(request, retryAttempts: retryAttempts, retryDelay: retryDelay)
    }
    
    private func performRequest<T: Decodable>(_ request: URLRequest, retryAttempts: Int, retryDelay: TimeInterval) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown(URLError(.badServerResponse))
                }
                
                switch httpResponse.statusCode {
                case 200..<300:
                    return data
                case 429:
                    throw APIError.rateLimited
                default:
                    throw APIError.badResponse(statusCode: httpResponse.statusCode)
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else if error is DecodingError {
                    return APIError.decodingError
                } else {
                    return APIError.unknown(error)
                }
            }
            .flatMap { result in
                Just(result).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<T, Error> in
                // Request retry logic for error 429 `tooManyRequests`
                if case APIError.rateLimited = error, retryAttempts > 0 {
                    // Retry after a delay
                    return Just(())
                        .delay(for: .seconds(retryDelay), scheduler: DispatchQueue.main)
                        .flatMap { self.performRequest(request, retryAttempts: retryAttempts - 1, retryDelay: retryDelay * 2) }
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func cancelAllTasks() {
        session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }
    
}
