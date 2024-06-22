//
//  NoteListView.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/23.
//

import SwiftUI

struct NoteListView: View {
    var noteList: Array<Note>
    var navigationTitle: String {
        let parentNote = notes.first(where: { $0.noteId == noteList[0].parentNoteIds[0] })
        return parentNote?.title ?? "Notes"
    }
    var body: some View {
        List(noteList, id: \.id) { note in
            NavigationLink {
                if !note.isFolder {
                    NoteContentView(note: note)
                } else {
                    NoteListView(noteList: notes.filter {
                        $0.parentNoteIds.contains(note.noteId)
                    })
                }
            } label: {
                NoteRow(note: note)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

#Preview {
    NavigationStack {
        NoteListView(noteList: notes.filter {
            $0.parentNoteIds.contains("root")
        })
    }
}
