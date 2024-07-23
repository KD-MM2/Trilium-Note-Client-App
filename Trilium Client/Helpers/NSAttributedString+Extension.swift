//
//  NSAttributedString+Extension.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/07/23.
//

import Foundation

extension NSAttributedString {
    func toHtml() -> String? {
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        do {
            let htmlData = try data(from: NSRange(location: 0, length: length),
                                    documentAttributes: documentAttributes)
            if let htmlString = String(data: htmlData, encoding: .utf8) {
                return cleanUpHtml(htmlString)
            }
        } catch {
            print("Error converting to HTML: \(error)")
        }
        return nil
    }
    
    private func cleanUpHtml(_ html: String) -> String {
        // Remove XML declaration
        var cleanHtml = html.replacingOccurrences(of: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>", with: "")
        
        // Remove DOCTYPE
        cleanHtml = cleanHtml.replacingOccurrences(of: "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">", with: "")
        
        // Remove html and body tags
        cleanHtml = cleanHtml.replacingOccurrences(of: "<html><body>", with: "")
        cleanHtml = cleanHtml.replacingOccurrences(of: "</body></html>", with: "")
        
        // Trim whitespace
        cleanHtml = cleanHtml.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanHtml
    }
}
