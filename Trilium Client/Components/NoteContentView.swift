//
//  NoteContentView.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/23.
//

import SwiftUI

struct NoteContentView: View {
    var note: Note
    var body: some View {
        Text(note.noteId)
        Button {
            print(note.noteId)
        } label: {
            Text("print")
        }
    }
}

//#Preview {
//    NoteContentView(note: NotesViewModel.shared.notes[0])
//}
