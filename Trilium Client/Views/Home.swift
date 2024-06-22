//
//  Home.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/22.
//

import SwiftUI
import Foundation

struct Home: View {
    var root: Array<Note> {
        return notes.filter {
            $0.parentNoteIds.contains("root")
        }
    }
    var body: some View {
        NavigationStack{
            NoteListView(noteList: root)
        }
    }
}

#Preview {
    Home()
}
