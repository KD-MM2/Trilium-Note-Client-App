//
//  GettingStarted.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/28.
//

import SwiftUI

struct GettingStarted: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        Spacer()
        Image("IconColor")
        Text("Trilium Notes Client")
        Spacer()
        Button {
            router.navigateTo(.home)
        } label: {
            Text("Getting started")
        }
        .buttonStyle(.borderedProminent)
        
        Spacer()
    }
}

#Preview {
    GettingStarted()
}
