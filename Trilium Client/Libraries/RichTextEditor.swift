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
    @State private var tempSelectedRange: NSRange = NSRange()
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
            currentFontSize: $currentFontSize,
            onLink: { linkUrl in
                print("onLink \(linkUrl)")
                self.applyLinkStyle(linkUrl: linkUrl)
                //                                self.applyStyle(.link)
            },
            onCode: { self.applyStyle(.code) }
        )).view!
        
        let container = UIStackView(arrangedSubviews: [toolbar, textView])
        container.axis = .vertical
        
        return container
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        //        if let hostingView = uiView.subviews.last {
        //            hostingView.isHidden = !showURLDialog
        //        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func applyStyle(_ style: TextStyle) {
        let selectedRange = textView.selectedRange
        
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
            break
            //            if currentAttributes[.link] != nil {
            //                // If link is present, remove it
            //                attributesToRemove[.link] = currentAttributes[.link] as Any
            //            } else {
            //                // If no link, add it
            //                // Here we're using a placeholder URL. In a real app, you'd want to prompt the user for the URL.
            //                let url = URL(string: "https://example.com")!
            //                textView.textStorage.addAttribute(.link, value: url, range: selectedRange)
            //            }
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
        //        let selectedRange = textView.selectedRange
        
        // If no text is selected, return
        if self.tempSelectedRange.length == 0 {
            print("applyLinkStyle: No text selected")
            return
        }
        
        let currentAttributes = textView.attributedText.attributes(at: self.tempSelectedRange.location, effectiveRange: nil)
        
        if currentAttributes[.link] != nil {
            // If link is present, remove it
            //                attributesToRemove[.link] = currentAttributes[.link] as Any
            textView.textStorage.removeAttribute(.link, range: self.tempSelectedRange)
        } else {
            // If no link, add it
            // Here we're using a placeholder URL. In a real app, you'd want to prompt the user for the URL.
            let url = URL(string: linkUrl)!
            textView.textStorage.addAttribute(.link, value: url, range: self.tempSelectedRange)
        }
    }
    
    func increaseFontSize() {
        modifyFontSize(by: 1)
    }
    
    func decreaseFontSize() {
        modifyFontSize(by: -1)
    }
    
    private func modifyFontSize(by delta: CGFloat) {
        let selectedRange = textView.selectedRange
        
        // If no text is selected, return
        if selectedRange.length == 0 { return }
        
        let currentAttributes = textView.attributedText.attributes(at: selectedRange.location, effectiveRange: nil)
        
        if let font = currentAttributes[.font] as? UIFont {
            let newSize = max(font.pointSize + delta, 1) // Ensure font size doesn't go below 1
            applyStyle(.fontSize(newSize))
            currentFontSize = newSize
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
            let selectedRange = textView.selectedRange
            if selectedRange.length == 0 { return }
            parent.tempSelectedRange = selectedRange
            
        }
        
    }
}

enum TextStyle {
    case bold, italic, underline, strikethrough, fontSize(CGFloat), link, code
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

