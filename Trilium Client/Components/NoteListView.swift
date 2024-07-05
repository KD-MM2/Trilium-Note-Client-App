//
//  NoteListView.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/23.
//

import SwiftUI

struct NoteListView: View {
    @ObservedObject var notesViewModel: NotesViewModel
    var noteList: [Note]
    var navigationTitle: String {
        return notesViewModel.getParentTitle(childNoteId: noteList.count > 0 ? noteList[0].parentNoteIds[0] : "" )
    }
    
    var body: some View {
        List(noteList, id: \.id) { note in
            NavigationLink {
                if !note.isFolder {
                    NoteContentView(note: note)
                } else {
                    NoteListView(notesViewModel: notesViewModel, noteList: notesViewModel.notes.filter {
                        $0.parentNoteIds.contains(note.noteId)
                    })
                }
            } label: {
                NoteRow(notesViewModel: notesViewModel, note: note)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            Menu {
                Section("Actions") {
                    Button("Create note") {}
                    Button("...") {}
                }
                
                Button {} label: {
                    Label("Add to Favorites", systemImage: "heart")
                }
                
                Divider()
                
                Button(role: .destructive) {} label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Label("Menu", systemImage: "plus")
            }
        })
    }
}

//#Preview {
//    @EnvironmentObject var notesViewModel: NotesViewModel
//    NavigationStack {
//        NoteListView(notesViewModel: notesViewModel, noteList: notesViewModel.notes)
//    }
//}
