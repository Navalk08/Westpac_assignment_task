//
//  Westpac_TechnicalTaskApp.swift
//  Westpac_TechnicalTask
//
//  Created by Naval on 24/07/24.
//

import SwiftUI

@main
struct Westpac_TechnicalTaskApp: App {
    @StateObject private var creditViewModel = CreditCardViewModel()
    @StateObject private var splashViewModel = SplashViewModel()
    
    var body: some Scene {
        WindowGroup {
            if splashViewModel.isSplashFinished {
                CreditCardListView(viewModel: creditViewModel)
            } else {
                SplashScreenView()
                    .onAppear {
                        splashViewModel.startSplashTimer()
                    }
            }
        }
    }
}
