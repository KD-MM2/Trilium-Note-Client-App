//
//  APIHelper.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/23.
//

import Alamofire
import Foundation

struct AuthResponse: Decodable {
    let authToken: String
}

class TriliumAPI {
    static var shared = TriliumAPI(baseURL: "", authToken: "", password: "")
    
    private var baseURL: String
    private var authToken: String
    private var password: String
    
    init(baseURL: String, authToken: String, password: String!) {
        self.baseURL = baseURL
        self.authToken = authToken
        self.password = password ?? ""
    }
    
    private var headers: HTTPHeaders {
        return [
            "Authorization": authToken,
            "Content-Type": "application/json",
        ]
    }
    
    static func updateSharedInstance(baseURL: String, authToken: String, password: String?) {
        TriliumAPI.shared = TriliumAPI(baseURL: baseURL, authToken: authToken, password: password)
    }
    
    // MARK: - Authentication
    
    func loginWithPassword(completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "\(baseURL)/etapi/auth/login"
        let parameters: [String: Any] = ["password": password]
        AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: AuthResponse.self) { response in
                switch response.result {
                case let .success(authResponse):
                    self.authToken = authResponse.authToken
                    completion(.success(authResponse.authToken))
                case let .failure(error):
                    print("Error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - App Info
    
    func getAppInfo(completion: @escaping (Result<AppInfo, Error>) -> Void) {
        let endpoint = "\(baseURL)/etapi/app-info"
        print(endpoint)
        print(headers)
        AF.request(endpoint, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: AppInfo.self) { response in
                switch response.result {
                case let .success(appInfo):
                    completion(.success(appInfo))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Notes
    
    func createNote(parentNoteId: String, title: String, type: String, content: String, completion: @escaping (Result<Note, Error>) -> Void) {
        let endpoint = "\(baseURL)/etapi/create-note"
        let parameters: [String: Any] = [
            "parentNoteId": parentNoteId,
            "title": title,
            "type": type,
            "content": content,
        ]
        
        AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: NoteWithBranch.self) { response in
                switch response.result {
                case let .success(noteWithBranch):
                    completion(.success(noteWithBranch.note))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
    
    func getNote(noteId: String, completion: @escaping (Result<Note, Error>) -> Void) {
        let endpoint = "\(baseURL)/etapi/notes/\(noteId)"
        
        AF.request(endpoint, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: Note.self) { response in
                switch response.result {
                case let .success(note):
                    completion(.success(note))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
    
    func updateNote(noteId: String, updates: [String: Any], completion: @escaping (Result<Note, Error>) -> Void) {
        let endpoint = "\(baseURL)/etapi/notes/\(noteId)"
        
        AF.request(endpoint, method: .patch, parameters: updates, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: Note.self) { response in
                switch response.result {
                case let .success(note):
                    completion(.success(note))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
    
    func deleteNote(noteId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = "\(baseURL)/etapi/notes/\(noteId)"
        
        AF.request(endpoint, method: .delete, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Search
    
    func searchNotes(query: String, completion: @escaping (Result<[Note], Error>) -> Void) {
        let endpoint = "\(baseURL)/etapi/notes"
        let parameters: [String: Any] = ["search": query]
        
        print("Search Notes: \(baseURL), \(endpoint)")
        
        AF.request(endpoint, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: SearchResponse.self) { response in
                switch response.result {
                case let .success(searchResponse):
                    completion(.success(searchResponse.results))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
}

func loginToInstance(instanceUrl: String, instancePassword: String?, instanceEtapiToken: String?, completion: @escaping (Result<Any, Error>) -> Void) {
    let useEtapiToken = instanceEtapiToken != nil && !instanceEtapiToken!.isEmpty
    let apiHelper = TriliumAPI(baseURL: instanceUrl, authToken: instanceEtapiToken ?? "", password: instancePassword ?? "")
    if useEtapiToken {
        print("Using ETAPI Token")
        apiHelper.getAppInfo { result in
            switch result {
            case .success:
                print("Verify Auth Token success")
                TriliumAPI.updateSharedInstance(baseURL: instanceUrl, authToken: instanceEtapiToken!, password: instancePassword)
                completion(.success(result))
            case let .failure(error):
                print("Error: \(error)")
            }
        }
    } else {
        print("Using Password")
        apiHelper.loginWithPassword { result in
            switch result {
            case let .success(authToken):
                print("Auth Token: \(authToken)")
                TriliumAPI.updateSharedInstance(baseURL: instanceUrl, authToken: authToken, password: instancePassword)
                completion(.success(authToken))
            case let .failure(error):
                print("Error: \(error)")
            }
        }
    }
}
