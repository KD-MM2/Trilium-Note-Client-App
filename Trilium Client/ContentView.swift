//
//  ContentView.swift
//  MFA
//
//  Created by Cao Thai Duong on 2024/03/20.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isSetupDone") private var isSetupDone = false
    
    var body: some View {
        if !hasCompletedOnboarding {
            GettingStartedView(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else if !isSetupDone {
            SetupView()
        } else {
            HomeView()
        }
    }
}


#Preview {
    ContentView()
}
