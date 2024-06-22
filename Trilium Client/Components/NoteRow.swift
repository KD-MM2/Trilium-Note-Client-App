//
//  NoteItem.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/23.
//

import SwiftUI

struct NoteRow: View {
    var note: Note
    var modifiedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: note.utcDateModified) else {
            return "Invalid date"
        }
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    var body: some View {
        
        VStack {
            HStack{
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

#Preview {
    Group{
    NoteRow(note: notes[64])
    NoteRow(note: notes[65])
    NoteRow(note: notes[66])
    NoteRow(note: notes[67])
    NoteRow(note: notes[68])
    }
}
