//
//  SplashViewModel.swift
//  Westpac_TechnicalTask
//
//  Created by Naval on 25/07/24.
//

import Foundation
import SwiftUI


class SplashViewModel: ObservableObject {
    @Published var isSplashFinished = false
    
    func startSplashTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                self.isSplashFinished = true
            }
        }
    }
}
