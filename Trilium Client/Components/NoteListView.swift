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
        return getParentTitle(childNoteId: noteList[0].parentNoteIds[0])
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
        .toolbar(content: {
            Menu {
                Section("Actions") {
                    Button("Create note") {  }
                    Button("...") {  }
                }
                
                Button { } label: {
                    Label("Add to Favorites", systemImage: "heart")
                }
                
                Divider()
                
                Button(role: .destructive) { } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Label("Menu", systemImage: "plus")
            }
            
        })
    }
    
}

#Preview {
    NavigationStack {
        NoteListView(noteList: getRoot())
    }
}
