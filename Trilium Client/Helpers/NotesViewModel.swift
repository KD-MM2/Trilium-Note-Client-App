//
//  ModelData.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/23.
//

import Foundation

class NotesViewModel: ObservableObject {
    @Published var notes: Array<Note> = []
    
    func fetchNotes() {
        TriliumAPI.shared.searchNotes(query: "''") { result in
            switch result {
            case let .success(fetchedNotes):
                DispatchQueue.main.async {
                    self.notes = fetchedNotes
                    //                    print(fetchedNotes)
                }
            case let .failure(error):
                print("Error fetching notes: \(error)")
                // Handle the error appropriately
            }
        }
    }
    
    func getRoot() -> Array<Note> {
        return self.notes.filter {
            $0.parentNoteIds.contains("root") && $0.noteId != "_hidden"
        }
    }
    
    
    func getParentTitle(childNoteId: String) -> String {
        let parentNote = self.notes.first(where: { $0.noteId == childNoteId })
        return parentNote?.title ?? "Notes"
    }
    
    func parseDateUtc(dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: dateString) else {
            return "Invalid date"
        }
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
