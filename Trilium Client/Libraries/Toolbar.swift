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
    let onIncreaseFontSize: () -> Void
    let onDecreaseFontSize: () -> Void
    @Binding var currentFontSize: CGFloat
    let onLink: () -> Void
    let onCode: () -> Void
    
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
            Button(action: onLink) { Image(systemName: "link") }
            Button(action: onCode) { Image(systemName: "chevron.left.forwardslash.chevron.right") }
            
            Button(action: onDecreaseFontSize) {
                Image(systemName: "minus.circle")
            }
            Text("\(Int(currentFontSize))")
                .frame(minWidth: 30)
            Button(action: onIncreaseFontSize) {
                Image(systemName: "plus.circle")
            }
            
        }
        .padding()
    }
}

#Preview {
    StyleToolbar(
        onBold: {},
        onItalic: {},
        onUnderline: {},
        onStrikethrough: {},
        onIncreaseFontSize: {},
        onDecreaseFontSize: {},
        currentFontSize: .constant(CGFloat(12.0)),
        onLink: {},
        onCode: {}
    )
}
