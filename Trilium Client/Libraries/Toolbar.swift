//
//  Toolbar.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/07/13.
//
import SwiftUI

struct StyleToolbar: View {
    let onBold: () -> Void
    let onItalic: () -> Void
    let onUnderline: () -> Void
    let onStrikethrough: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBold) {
                Image(systemName: "bold")
            }
            Button(action: onItalic) {
                Image(systemName: "italic")
            }
            Button(action: onUnderline) {
                Image(systemName: "underline")
            }
            Button(action: onStrikethrough) {
                Image(systemName: "strikethrough")
            }
        }
        .padding()
    }
}

//#Preview {
//    StyleToolbar()
//}
