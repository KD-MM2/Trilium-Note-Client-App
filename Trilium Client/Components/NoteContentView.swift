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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button{
            print(note.noteId)
        } label: {
            Text("print")
        }
    }
}

#Preview {
    NoteContentView(note: notes[0])
}
