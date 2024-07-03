//
//  Home.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/22.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var root: [Note] {
        return getRoot()
    }
    
    init() {
        print("Home view initialized")
    }
    
    var body: some View {
        NavigationView {
            NoteListView(noteList: root)
        }
        .toolbar(.hidden)
        .onAppear {
            print("Home view appeared")
        }
    }
}


#Preview {
    HomeView()
}
