//
//  RichTextEditor.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/07/13.
//

import Foundation
import SwiftUI
import UIKit
import WebKit

public class RichTextView: UITextView {}

public protocol RichTextViewRepresentable {
    var attributedString: NSAttributedString { get }
}

extension RichTextView: RichTextViewRepresentable {}

public extension RichTextView {
    var attributedString: NSAttributedString {
        get { attributedText ?? NSAttributedString(string: "") }
        set { attributedText = newValue }
    }
}

typealias ViewRepresentable = UIViewRepresentable
public struct RichTextEditor: ViewRepresentable {
    public init(text: Binding<NSAttributedString>) {
        _attributedString = text
    }
    
    @Binding public var attributedString: NSAttributedString
    @State private var currentFontSize: CGFloat = 12
    @State private var currentFgColor: UIColor = .black
    @State private var currentBgColor: UIColor = .white
    @State private var tempSelectedRange: NSRange = NSRange()
    @State private var keyboardHeight: CGFloat = 0
    
    // @Binding public var htmlString: String
    
    // public init(htmlString: Binding<String>) {
    //     _htmlString = htmlString
    // }
    
    public let textView = RichTextView()
    
    public func makeUIView(context: Context) -> some UIView {
        textView.attributedString = attributedString
        textView.delegate = context.coordinator
        
        let toolbar = UIHostingController(rootView: StyleToolbar(
            onBold: { self.applyStyle(.bold) },
            onItalic: { self.applyStyle(.italic) },
            onUnderline: { self.applyStyle(.underline) },
            onStrikethrough: { self.applyStyle(.strikethrough) },
            onIncreaseFontSize: {self.increaseFontSize()},
            onDecreaseFontSize: {self.decreaseFontSize()},
            onLink: { linkUrl in self.applyLinkStyle(linkUrl: linkUrl) },
            onCode: { self.applyStyle(.code) },
            onFgColor: { color in self.applyStyle(.fgColor(color)) },
            onBgColor: { color in self.applyStyle(.bgColor(color)) },
            onSetFontSize: { fontSize in self.setFontSize(to: fontSize) },
            currentFontSize: $currentFontSize,
            currentFgColor: $currentFgColor,
            currentBgColor: $currentBgColor
        )).view!
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        textView.inputAccessoryView = toolbar
        
        return textView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        if let textView = uiView as? UITextView {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            textView.scrollIndicatorInsets = textView.contentInset
        }
    }
    
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func applyStyle(_ style: TextStyle) {
        let selectedRange = self.tempSelectedRange
        
        // If no text is selected, return
        if selectedRange.length == 0 { return }
        
        let currentAttributes = textView.attributedText.attributes(at: selectedRange.location, effectiveRange: nil)
        var newAttributes: [NSAttributedString.Key: Any] = [:]
        var attributesToRemove: [NSAttributedString.Key: Any] = [:]
        
        switch style {
        case .bold:
            if let font = currentAttributes[.font] as? UIFont {
                newAttributes[.font] = font.isBold ? font.withoutBold() : font.withBold()
            }
        case .italic:
            if let font = currentAttributes[.font] as? UIFont {
                newAttributes[.font] = font.isItalic ? font.withoutItalic() : font.withItalic()
            }
        case .underline:
            if currentAttributes[.underlineStyle] != nil {
                attributesToRemove[.underlineStyle] = currentAttributes[.underlineStyle] as Any
            } else {
                newAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
        case .strikethrough:
            if currentAttributes[.strikethroughStyle] != nil {
                attributesToRemove[.strikethroughStyle] = currentAttributes[.strikethroughStyle] as Any
            } else {
                newAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            }
        case .fontSize(let size):
            if let font = currentAttributes[.font] as? UIFont {
                let newFont = font.withSize(size)
                textView.textStorage.addAttribute(.font, value: newFont, range: selectedRange)
                currentFontSize = size
            }
        case .link:
            // link is now handled separately
            break
        case .code:
            if let font = currentAttributes[.font] as? UIFont {
                if font.fontName.contains("Menlo") || font.fontName.contains("Courier") {
                    // If it's already a monospace font, revert to system font
                    let newFont = UIFont.systemFont(ofSize: font.pointSize)
                    textView.textStorage.addAttribute(.font, value: newFont, range: selectedRange)
                    textView.textStorage.removeAttribute(.backgroundColor, range: selectedRange)
                } else {
                    // If it's not a monospace font, change to one and add background color
                    let newFont = UIFont(name: "Menlo-Regular", size: font.pointSize) ?? font
                    textView.textStorage.addAttribute(.font, value: newFont, range: selectedRange)
                    textView.textStorage.addAttribute(.backgroundColor, value: UIColor.lightGray.withAlphaComponent(0.2), range: selectedRange)
                }
            }
            
        case .fgColor(let color):
            newAttributes[.foregroundColor] = color
            currentFgColor = color
            
        case .bgColor(let color):
            newAttributes[.backgroundColor] = color
            currentBgColor = color
        }
        
        
        if attributesToRemove.count > 0 {
            for (key, _) in attributesToRemove {
                textView.textStorage.removeAttribute(key, range: selectedRange)
            }
        }
        
        textView.textStorage.addAttributes(newAttributes, range: selectedRange)
        attributedString = textView.attributedText ?? NSAttributedString()
    }
    
    func applyLinkStyle(linkUrl: String) {
        // If no text is selected, return
        if self.tempSelectedRange.length == 0 { return }
        
        let currentAttributes = textView.attributedText.attributes(at: self.tempSelectedRange.location, effectiveRange: nil)
        
        if currentAttributes[.link] != nil {
            textView.textStorage.removeAttribute(.link, range: self.tempSelectedRange)
        } else {
            if let url = URL(string: linkUrl) {
                textView.textStorage.addAttribute(.link, value: url, range: self.tempSelectedRange)
            }
            
        }
    }
    
    func increaseFontSize() {
        modifyFontSize(by: 1)
    }
    
    func decreaseFontSize() {
        modifyFontSize(by: -1)
    }
    
    func setFontSize(to size: CGFloat) {
        modifyFontSize(to: size)
    }
    
    private func modifyFontSize(by delta: CGFloat? = nil, to newSize: CGFloat? = nil) {
        let selectedRange = self.tempSelectedRange
        
        // If no text is selected, return
        if selectedRange.length == 0 { return }
        
        let currentAttributes = textView.attributedText.attributes(at: selectedRange.location, effectiveRange: nil)
        
        if let font = currentAttributes[.font] as? UIFont {
            let updatedSize: CGFloat
            if let delta = delta {
                updatedSize = max(font.pointSize + delta, 1) // Ensure font size doesn't go below 1
            } else if let newSize = newSize {
                updatedSize = max(newSize, 1) // Ensure font size doesn't go below 1
            } else {
                return // If neither delta nor newSize is provided, do nothing
            }
            
            applyStyle(.fontSize(updatedSize))
            currentFontSize = updatedSize
        }
    }
    
    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        public func textViewDidChange(_ textView: UITextView) {
            parent.attributedString = textView.attributedText
        }
        
        public func textViewDidChangeSelection(_ textView: UITextView) {
            if let font = textView.font {
                parent.currentFontSize = font.pointSize
            }
            if let fgColor = textView.textColor {
                parent.currentFgColor = fgColor
            }
            if let bgColor = textView.backgroundColor {
                parent.currentBgColor = bgColor
            }
            let selectedRange = textView.selectedRange
            if selectedRange.length == 0 { return }
            parent.tempSelectedRange = selectedRange
            
        }
        
        public func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {
            NotificationCenter.default.removeObserver(self)
        }
        
    }
}

enum TextStyle {
    case bold, italic, underline, strikethrough, fontSize(CGFloat), link, code, fgColor(UIColor), bgColor(UIColor)
}

extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    func withBold() -> UIFont {
        return withTrait(.traitBold)
    }
    
    func withoutBold() -> UIFont {
        return withoutTrait(.traitBold)
    }
    
    func withItalic() -> UIFont {
        return withTrait(.traitItalic)
    }
    
    func withoutItalic() -> UIFont {
        return withoutTrait(.traitItalic)
    }
    
    private func withTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.union(trait)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    private func withoutTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.subtracting(trait)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

