//
//  Trilium_ClientApp.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/22.
//

import SwiftUI

@main
struct Trilium_ClientApp: App {
    var isSetupDone: Bool {
        return UserDefaults.standard.bool(forKey: "isSetupDone")
    }
    
    var body: some Scene {
        WindowGroup {
            if (!isSetupDone) {
                Setup()
            } else {
                Home()
            }
            
        }
    }
}
