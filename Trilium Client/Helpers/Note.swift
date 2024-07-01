//
//  Note.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/22.
//

import Foundation


struct Attribute: Hashable, Codable {
    var attributeId: String
    var noteId: String
    var type: String
    var name: String
    var value: String
    var position: Int
    var isInheritable: Bool
    var utcDateModified: String
}

struct Note: Hashable, Codable, Identifiable {
    var noteId: String
    var isProtected: Bool
    var title: String
    var mime: String
    var blobId: String
    var dateCreated: String
    var dateModified: String
    var utcDateCreated: String
    var utcDateModified: String
    var parentNoteIds: Array<String>
    var childNoteIds: Array<String>
    var parentBranchIds: Array<String>
    var childBranchIds: Array<String>
    var attributes: Array<Attribute>
    var isFolder: Bool {
        return childBranchIds.count > 0
    }
    var id: String {
        return noteId
    }
}

struct NoteWithBranch: Codable {
    let note: Note
    let branch: Branch
}

struct Branch: Codable {
    let branchId: String
    let noteId: String
    let parentNoteId: String
    // Add other properties as needed
}

struct SearchResponse: Codable {
    let results: [Note]
}

struct AppInfo: Codable {
    let appVersion: String
    let dbVersion: Int
    let nodeVersion: String
    let syncVersion: Int
    let buildDate: String
    let buildRevision: String
    let dataDirectory: String
    let clipperProtocolVersion: String
    let utcDateTime: String
}

