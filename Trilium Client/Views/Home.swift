//
//  Home.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/22.
//

import Foundation
import SwiftUI

struct Home: View {
    @EnvironmentObject var router: Router
    
    var root: [Note] {
        return getRoot()
    }
    
    init() {
            print("Home view initialized")
        }

    var body: some View {
        NavigationStack {
            NoteListView(noteList: root)
        }
        .toolbar(.hidden)
        .onAppear {
            print("Home view appeared")

        }
    }
}

#Preview {
    Home()
}
