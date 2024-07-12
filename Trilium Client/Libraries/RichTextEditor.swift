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
    
    public let textView = RichTextView()
    
    public func makeUIView(context _: Context) -> some UIView {
        textView.attributedString = attributedString
        return textView
    }
    
    public func updateUIView(_: UIViewType, context _: Context) {}
}

// #Preview {
//    RichTextEditor()
// }
