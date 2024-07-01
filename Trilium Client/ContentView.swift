//
//  ContentView.swift
//  MFA
//
//  Created by Cao Thai Duong on 2024/03/20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var router: Router
    var isSetupDone: Bool {
        return UserDefaults.standard.bool(forKey: "isSetupDone")
    }

    var body: some View {
        RouterView {
            GettingStarted()
        }

    }
}

#Preview {
    ContentView()
}
