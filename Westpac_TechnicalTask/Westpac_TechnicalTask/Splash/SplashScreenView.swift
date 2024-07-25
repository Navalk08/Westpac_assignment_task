//
//  SplashScreenView.swift
//  Westpac_TechnicalTask
//
//  Created by Naval on 25/07/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.yellow
                .edgesIgnoringSafeArea(.all)
            
            Text("Westpac Assignment")
                .font(.title)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    SplashScreenView()
}
