//
//  NoteRow.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/23.
//

import SwiftUI

struct NoteRow: View {
    @ObservedObject var notesViewModel: NotesViewModel
    var note: Note
    var modifiedDate: String {
        return notesViewModel.parseDateUtc(dateString: note.utcDateModified)
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: note.isFolder ? "folder" : "note.text")
                Text(note.title)
                    .font(.system(size: 16))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Last modified: \(modifiedDate)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.all, 8)
    }
}

//#Preview {
//    Group {
//        NoteRow(note: NotesViewModel.shared.notes[0])
//        NoteRow(note: NotesViewModel.shared.notes[20])
//    }
//}
