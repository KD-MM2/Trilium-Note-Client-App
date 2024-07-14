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
    
    @Binding
    public var attributedString: NSAttributedString
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
            onStrikethrough: { self.applyStyle(.strikethrough) }
        )).view!
        
        let container = UIStackView(arrangedSubviews: [toolbar, textView])
        container.axis = .vertical
        
        return container
    }
    
    public func updateUIView(_: UIViewType, context _: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func applyStyle(_ style: TextStyle) {
        let selectedRange = textView.selectedRange
        
        // If no text is selected, return
        if selectedRange.length == 0 { return }
        
        let currentAttributes = textView.attributedText.attributes(at: selectedRange.location, effectiveRange: nil)
        var newAttributes: [NSAttributedString.Key: Any] = [:]
        
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
            if let underlineStyle = currentAttributes[.underlineStyle] as? Int {
                // If underline is present, remove it
                newAttributes[.underlineStyle] = nil
            } else {
                // If no underline, add it
                newAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
        case .strikethrough:
            if let strikethroughStyle = currentAttributes[.strikethroughStyle] as? Int {
                // If strikethrough is present, remove it
                newAttributes[.strikethroughStyle] = nil
            } else {
                // If no strikethrough, add it
                newAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            }
        }
        
        if style == .underline {
            // For underline, we need to remove the attribute if we're turning it off
            if newAttributes[.underlineStyle] == nil {
                textView.textStorage.removeAttribute(.underlineStyle, range: selectedRange)
            } else {
                textView.textStorage.addAttributes(newAttributes, range: selectedRange)
            }
        } else if style == .strikethrough {
            // For strikethrough, we need to remove the attribute if we're turning it off
            if newAttributes[.strikethroughStyle] == nil {
                textView.textStorage.removeAttribute(.strikethroughStyle, range: selectedRange)
            } else {
                textView.textStorage.addAttributes(newAttributes, range: selectedRange)
            }
        } else {
            textView.textStorage.addAttributes(newAttributes, range: selectedRange)
        }
        
        attributedString = textView.attributedText ?? NSAttributedString()
    }
    
    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        public func textViewDidChange(_ textView: UITextView) {
            parent.attributedString = textView.attributedText
        }
    }
}

enum TextStyle {
    case bold, italic, underline, strikethrough
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

// #Preview {
//    RichTextEditor()
// }
