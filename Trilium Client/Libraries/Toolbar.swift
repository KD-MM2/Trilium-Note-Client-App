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
    let onFgColor: (UIColor) -> Void
    let onBgColor: (UIColor) -> Void
    let onSetFontSize: (CGFloat) -> Void
    @Binding var currentFontSize: CGFloat
    @Binding var currentFgColor: UIColor
    @Binding var currentBgColor: UIColor
    @State private var showFgColorPicker = false
    @State private var showBgColorPicker = false
    
    private var fontSizes: [CGFloat] {
        let minSize = max(currentFontSize - 5, 1) // Ensure we don't go below 1
        let maxSize = currentFontSize + 5
        return stride(from: minSize, through: maxSize, by: 1).map { CGFloat($0) }
    }
    
    
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
    
    private let buttonSize: CGFloat = 20
    private func toolbarButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(width: buttonSize, height: buttonSize)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private func colorButton(systemName: String, color: Binding<UIColor>, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(color.wrappedValue))
                    .frame(width: buttonSize / 3, height: buttonSize / 3)
                    .offset(x: buttonSize / 1.5, y: -buttonSize / 2)
                Image(systemName: systemName)
                    .frame(width: buttonSize, height: buttonSize)
            }
        }
        .buttonStyle(.borderedProminent)
        
    }
    
    
    var body: some View {
        ScrollView(.horizontal) {
            
            HStack(spacing: 8) {
                toolbarButton(systemName: "bold", action: onBold)
                
                toolbarButton(systemName: "italic", action: onItalic)
                
                toolbarButton(systemName: "underline", action: onUnderline)
                
                toolbarButton(systemName: "strikethrough", action: onStrikethrough)
                
                toolbarButton(systemName: "link") {
                    presentLinkAlert { url in
                        onLink(url)
                    }
                }
                
                toolbarButton(systemName: "chevron.left.forwardslash.chevron.right", action: onCode)
                
                Divider()
                
                toolbarButton(systemName: "textformat.size.smaller", action: onDecreaseFontSize)
                
                Menu {
                    ForEach(fontSizes, id: \.self) { size in
                        Button(action: {
                            currentFontSize = size
                            onSetFontSize(size)
                        }) {
                            Text("\(Int(size))")
                            if (size == currentFontSize) {
                                Image(systemName: "checkmark")
                            }
                            
                        }
                    }
                } label: {
                    Text("\(Int(currentFontSize))")
                        .frame(width: buttonSize * 2.2, height: buttonSize * 1.7)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                
                toolbarButton(systemName: "textformat.size.larger", action: onIncreaseFontSize)
                
                Divider()
                
                colorButton(systemName: "paintbrush", color: $currentFgColor) {
                    showFgColorPicker = true
                }
                .background(ColorPickerController(isPresented: $showFgColorPicker) { pickedColor in
                    onFgColor(pickedColor)
                    showFgColorPicker = false
                })
                
                colorButton(systemName: "paintbrush.fill", color: $currentBgColor) {
                    showBgColorPicker = true
                }
                .background(ColorPickerController(isPresented: $showBgColorPicker) { pickedColor in
                    onBgColor(pickedColor)
                    showBgColorPicker = false
                })
                
            }
            .padding()
        }
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
        onFgColor: { selectedColor in },
        onBgColor: { selectedColor in },
        onSetFontSize: {fontSize in },
        currentFontSize: .constant(CGFloat(12.0)),
        currentFgColor: .constant(UIColor.black),
        currentBgColor: .constant(UIColor.white)
    )
}
