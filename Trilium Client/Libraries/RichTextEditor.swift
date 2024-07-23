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
    //    var onSave: ((NSAttributedString) -> Void)? { get set }
}

extension RichTextView: RichTextViewRepresentable {
    //    func attributedStringToHTML() -> String {
    //        guard let data = try? attributedString.data(from: NSRange(location: 0, length: attributedString.length),
    //                                                    documentAttributes: [.documentType: NSAttributedString.DocumentType.html]) else {
    //            return ""
    //        }
    //        return String(data: data, encoding: .utf8) ?? ""
    //    }
}

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
    @State private var tempSelectedRange: NSRange = .init()
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
            onIncreaseFontSize: { self.increaseFontSize() },
            onDecreaseFontSize: { self.decreaseFontSize() },
            onLink: { linkUrl in self.applyLinkStyle(linkUrl: linkUrl) },
            onCode: { self.applyStyle(.code) },
            onFgColor: { color in self.applyStyle(.fgColor(color)) },
            onBgColor: { color in self.applyStyle(.bgColor(color)) },
            onSetFontSize: { fontSize in self.setFontSize(to: fontSize) },
            onClearStyle: { self.clearAllStyles() },
            onSuperscript: { self.applySuperscript() },
            onSubscript: { self.applySubscript() },
            onAlignLeft: { self.applyStyle(.alignLeft) },
            onAlignCenter: { self.applyStyle(.alignCenter) },
            onAlignRight: { self.applyStyle(.alignRight) },
            onIndent: { self.applyStyle(.indent) },
            onOutdent: { self.applyStyle(.outdent) },
            onBulletList: { self.applyStyle(.bulletList) },
            onNumberedList: { self.applyStyle(.numberedList) },
            onIncreaseLetterSpacing: { self.increaseLetterSpacing() },
            onDecreaseLetterSpacing: { self.decreaseLetterSpacing() },
            onHideKeyboard: { self.hideKeyboard() },
            
            currentFontSize: $currentFontSize,
            currentFgColor: $currentFgColor,
            currentBgColor: $currentBgColor
        )).view!
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        textView.inputAccessoryView = toolbar
        textView.inputAccessoryView?.translatesAutoresizingMaskIntoConstraints = true
        textView.inputAccessoryView?.autoresizingMask = .flexibleHeight
        
        return textView
    }
    
    public func updateUIView(_ uiView: UIViewType, context _: Context) {
        if let textView = uiView as? UITextView {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            textView.scrollIndicatorInsets = textView.contentInset
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func applyStyle(_ style: TextStyle) {
        let selectedRange = tempSelectedRange
        
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
            
        case let .fontSize(size):
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
            
        case let .fgColor(color):
            newAttributes[.foregroundColor] = color
            currentFgColor = color
            
        case let .bgColor(color):
            newAttributes[.backgroundColor] = color
            currentBgColor = color
            
        case .superscript:
            // if currently exist superscript, remove it
            if let currentBaseline = currentAttributes[.baselineOffset] as? Int {
                if currentBaseline == 6 {
                    attributesToRemove[.baselineOffset] = currentBaseline
                    setFontSize(to: 12)
                } else if currentBaseline == -6 {
                    newAttributes[.baselineOffset] = 6
                }
            } else {
                newAttributes[.baselineOffset] = 6
                setFontSize(to: 10)
            }
            
        case .subscrpt:
            if let currentBaseline = currentAttributes[.baselineOffset] as? Int {
                if currentBaseline == -6 {
                    attributesToRemove[.baselineOffset] = currentBaseline
                    setFontSize(to: 12)
                } else if currentBaseline == 6 {
                    newAttributes[.baselineOffset] = -6
                }
                
            } else {
                newAttributes[.baselineOffset] = -6
                setFontSize(to: 10)
            }
            
        case .alignLeft:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            newAttributes[.paragraphStyle] = paragraphStyle
            
        case .alignCenter:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            newAttributes[.paragraphStyle] = paragraphStyle
            
        case .alignRight:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            newAttributes[.paragraphStyle] = paragraphStyle
            
        case .indent:
            let paragraphStyle = (currentAttributes[.paragraphStyle] as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
            paragraphStyle.headIndent += 20
            paragraphStyle.firstLineHeadIndent += 20
            newAttributes[.paragraphStyle] = paragraphStyle
            
        case .outdent:
            let paragraphStyle = (currentAttributes[.paragraphStyle] as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
            paragraphStyle.headIndent = max(paragraphStyle.headIndent - 20, 0)
            paragraphStyle.firstLineHeadIndent = max(paragraphStyle.firstLineHeadIndent - 20, 0)
            newAttributes[.paragraphStyle] = paragraphStyle
            
        case .bulletList:
            let paragraphStyle = (currentAttributes[.paragraphStyle] as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
            if paragraphStyle.textLists.isEmpty {
                let textList = NSTextList(markerFormat: .disc, options: 0)
                paragraphStyle.textLists = [textList]
            } else {
                paragraphStyle.textLists = []
            }
            newAttributes[.paragraphStyle] = paragraphStyle
            
        case .numberedList:
            let paragraphStyle = (currentAttributes[.paragraphStyle] as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
            if paragraphStyle.textLists.isEmpty {
                let textList = NSTextList(markerFormat: .decimal, options: 0)
                paragraphStyle.textLists = [textList]
            } else {
                paragraphStyle.textLists = []
            }
            newAttributes[.paragraphStyle] = paragraphStyle
            
        case let .letterSpacing(spacing):
            newAttributes[.kern] = spacing
        }
        
        if attributesToRemove.count > 0 {
            for (key, _) in attributesToRemove {
                textView.textStorage.removeAttribute(key, range: selectedRange)
            }
        }
        
        textView.textStorage.addAttributes(newAttributes, range: selectedRange)
        attributedString = textView.attributedText ?? NSAttributedString()
    }
    
    private func applyLinkStyle(linkUrl: String) {
        // If no text is selected, return
        if tempSelectedRange.length == 0 { return }
        
        let currentAttributes = textView.attributedText.attributes(at: tempSelectedRange.location, effectiveRange: nil)
        
        if currentAttributes[.link] != nil {
            textView.textStorage.removeAttribute(.link, range: tempSelectedRange)
        } else {
            if let url = URL(string: linkUrl) {
                textView.textStorage.addAttribute(.link, value: url, range: tempSelectedRange)
            }
        }
    }
    
    private func increaseFontSize() {
        modifyFontSize(by: 1)
    }
    
    private func decreaseFontSize() {
        modifyFontSize(by: -1)
    }
    
    private func setFontSize(to size: CGFloat) {
        modifyFontSize(to: size)
    }
    
    private func modifyFontSize(by delta: CGFloat? = nil, to newSize: CGFloat? = nil) {
        let selectedRange = tempSelectedRange
        
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
    
    private func clearAllStyles() {
        let selectedRange = tempSelectedRange
        
        // If no text is selected, return
        if selectedRange.length == 0 { return }
        
        let defaultFont = UIFont.systemFont(ofSize: 12) // You can adjust this default size
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: defaultFont,
            .foregroundColor: UIColor.black,
            .backgroundColor: UIColor.clear,
        ]
        
        textView.textStorage.setAttributes(defaultAttributes, range: selectedRange)
        
        // Remove any other attributes that might be present
        textView.textStorage.removeAttribute(.underlineStyle, range: selectedRange)
        textView.textStorage.removeAttribute(.strikethroughStyle, range: selectedRange)
        textView.textStorage.removeAttribute(.link, range: selectedRange)
        
        // Update the current font size and colors
        currentFontSize = defaultFont.pointSize
        currentFgColor = .black
        currentBgColor = .clear
        
        attributedString = textView.attributedText ?? NSAttributedString()
    }
    
    private func applySuperscript() {
        applyStyle(.superscript)
    }
    
    private func applySubscript() {
        applyStyle(.subscrpt)
    }
    
    private func increaseLetterSpacing() {
        let currentSpacing = textView.attributedText.attribute(.kern, at: tempSelectedRange.location, effectiveRange: nil) as? CGFloat ?? 0
        applyStyle(.letterSpacing(currentSpacing + 1))
    }
    
    private func decreaseLetterSpacing() {
        let currentSpacing = textView.attributedText.attribute(.kern, at: tempSelectedRange.location, effectiveRange: nil) as? CGFloat ?? 0
        applyStyle(.letterSpacing(max(currentSpacing - 1, -5))) // Prevent negative spacing below -5
    }
    
    private func hideKeyboard() {
        textView.resignFirstResponder()
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
        
        public func dismantleUIView(_: UIViewType, coordinator _: Coordinator) {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

enum TextStyle {
    case bold, italic, underline, strikethrough, fontSize(CGFloat), link, code, fgColor(UIColor), bgColor(UIColor), superscript, subscrpt, alignLeft, alignCenter, alignRight, indent, outdent, bulletList, numberedList, letterSpacing(CGFloat)
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
