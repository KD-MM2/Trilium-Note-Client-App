//
//  AlertControllerWrapper.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/07/16.
//

import SwiftUI

struct AlertControllerWrapper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var alertTitle: String
    var message: String
    var textFieldPlaceholder: String
    var onSave: (String) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = textFieldPlaceholder
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                isPresented = false
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                if let text = alert.textFields?.first?.text {
                    onSave(text)
                }
                isPresented = false
            })
            uiViewController.present(alert, animated: true)
        }
    }
}
