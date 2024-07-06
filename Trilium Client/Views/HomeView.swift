//
//  HomeView.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/22.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @AppStorage("instanceUrl") private var instanceUrl: String = ""
    @AppStorage("instanceEtapiToken") private var instanceEtapiToken: String = ""
    @AppStorage("instancePassword") private var instancePassword: String = ""
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var isLoading = true
    
    func login(completion: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                print("Login using ETAPI token: \(instanceEtapiToken)")
                loginToInstance(instanceUrl: instanceUrl, instancePassword: instancePassword, instanceEtapiToken: instanceEtapiToken, completion: { result in
                    switch result {
                    case let .success(response):
                        print("Login with token success: \(response)")
                        //                        instanceEtapiToken = authToken as! String
                        continuation.resume()
                        
                        completion()
                    case let .failure(error):
                        print("Login failed with error: \(error)")
                        continuation.resume()
                    }
                })
            }
        }
    }
    
    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Loading...")
            } else {
                NoteListView(notesViewModel: notesViewModel, noteList: notesViewModel.getRoot())
            }
        }
        .environmentObject(notesViewModel)
        .task {
            guard !notesViewModel.isLoaded else { return }
            await login {
                notesViewModel.fetchNotes()
            }
            isLoading = false
        }
        .toolbar(.hidden)
    }
}

#Preview {
    HomeView()
}
