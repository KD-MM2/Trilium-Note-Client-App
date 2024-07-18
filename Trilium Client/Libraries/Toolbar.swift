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
    let onLink: (String) -> Void
    let onCode: () -> Void
    @Binding var currentFontSize: CGFloat
    
    private func presentLinkAlert(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Enter link URL", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = "https://"
            textField.placeholder = "https://www.example.com"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let url = alert.textFields?.first?.text {
                completion(url)
            }
        })
        
        DispatchQueue.main.async {
            if let topController = UIApplication.topMostViewController() {
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    var body: some View {
        HStack {
            Button(action: onBold, label: {
                Image(systemName: "bold")
            })
            
            Button (action: onItalic, label: {
                Image(systemName: "italic")
            })
            
            Button (action: onUnderline, label: {
                Image(systemName: "underline")
            })
            
            Button(action: onStrikethrough, label: {
                Image(systemName: "strikethrough")
            })
            Button(action: {
                presentLinkAlert { url in
                    onLink(url)
                }
            }, label: {
                Image(systemName: "link")
            })
            
            Button(action: onCode, label: {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
            })
            
            Button (action: onDecreaseFontSize, label: {
                Image(systemName: "minus.circle")
            })
            
            Text("\(Int(currentFontSize))")
                .frame(minWidth: 30)
            
            Button(action: onIncreaseFontSize, label: {
                Image(systemName: "plus.circle")
            })
            
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
        onLink: { linkUrl in },
        onCode: {},
        currentFontSize: .constant(CGFloat(12.0))
    )
}
