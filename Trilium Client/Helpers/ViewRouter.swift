//
//  ViewRouter.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/27.
//
import SwiftUI

class Router: ObservableObject {
    @Published var path: [Destination] = []

    enum Destination: String, Hashable {
        case Setup, Home
    }

    static let shared: Router = .init()
}

