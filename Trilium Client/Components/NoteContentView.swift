//
//  NoteContentView.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/23.
//
// import RichTextKit
import MarkupEditor
import SwiftUI


struct NoteContentView: View {
    @ObservedObject var notesViewModel: NotesViewModel
    var note: Note
    @State var noteContent = NSAttributedString(string: "Note empty")
    @State var noteString: String = ""
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Loading...")
            } else {
//                MarkupEditorView(html: $noteString)
                RichTextEditor(text: $noteContent)
                    .cornerRadius(5)
//                    .frame(width: 500)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.3))
//        .ignoresSafeArea(.keyboard, edges: .bottom)
//        .ignoresSafeArea(.keyboard)
        .task {
            TriliumAPI.shared.getNoteContent(noteId: note.noteId, completion: { content in
                switch content {
                case let .success(response):
                    // Safely unwrap data from the response string
                    if let data = (response as String).data(using: .utf8, allowLossyConversion: true) {
                        do {
                            // Attempt to create an attributed string from HTML
                            let attributedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                            
                            // If you need to modify the paragraph style, do it here
                            let style = NSMutableParagraphStyle()
                            // Example style modifications can be added here, e.g., style.alignment = .justified
                            
                            // Create a mutable copy to add the paragraph style
                            let mutableAttributeText = NSMutableAttributedString(attributedString: attributedString)
                            let fullRange = NSRange(location: 0, length: attributedString.length)
                            mutableAttributeText.addAttribute(.paragraphStyle, value: style, range: fullRange)
                            
                            // Update your content
                            noteContent = mutableAttributeText
                        } catch {
                            print("Error creating attributed string from HTML: \(error)")
                        }
                    } else {
                        print("Error: Data conversion to UTF-8 failed.")
                    }
                    noteString = response
                    isLoading = false
                case let .failure(error):
                    print("Error: \(error)")
                }
            })
        }
    }
}

// #Preview {
//    NoteContentView(note: NotesViewModel.shared.notes[0])
// }
