//
//  GettingStarted.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/28.
//

import SwiftUI

struct GettingStartedView: View {
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Image("IconColor")
            Text("Trilium Notes Client")
            Spacer()
            
            Button(action: {
                hasCompletedOnboarding = true
                Router.shared.path.append(.Setup)
            }, label: {
                Text("Getting started")
            })
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
}

#Preview {
    GettingStartedView(hasCompletedOnboarding: .constant(false))
}
