//
//  RouterView.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/07/03.
//

import SwiftUI

struct RouterView: View {
    @StateObject private var navPath = Router.shared
    
    var body: some View {
        NavigationStack(path: $navPath.path) {
            ContentView()
                .toolbar(.hidden)
                .navigationDestination(for: Router.Destination.self) { destination in
                    switch destination {
                    case .Setup:
                        SetupView()
                    case .Home:
                        HomeView()
                    }
                }
        }
    }
}


#Preview {
    RouterView()
}
