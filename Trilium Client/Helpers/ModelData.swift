//
//  ModelData.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/23.
//

import Foundation


var notes: Array<Note> = load("noteData.json")


func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

func getRoot() -> Array<Note> {
    return notes.filter {
        $0.parentNoteIds.contains("root") && $0.noteId != "_hidden"
    }
}

func getParentTitle(childNoteId: String) -> String {
    let parentNote = getRoot().first(where: { $0.noteId == childNoteId })
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
