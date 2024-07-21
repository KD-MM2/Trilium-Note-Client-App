//
//  ColorPickerController.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/07/19.
//

import Foundation
import UIKit
import SwiftUI

struct ColorPickerController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onColorPicked: (UIColor) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let colorPicker = UIColorPickerViewController()
            colorPicker.delegate = context.coordinator
            uiViewController.present(colorPicker, animated: true) {
                self.isPresented = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, onColorPicked: onColorPicked)
    }
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var parent: ColorPickerController
        let onColorPicked: (UIColor) -> Void
        
        init(_ parent: ColorPickerController, onColorPicked: @escaping (UIColor) -> Void) {
            self.parent = parent
            self.onColorPicked = onColorPicked
        }
        
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            onColorPicked(viewController.selectedColor)
            parent.isPresented = false
            viewController.dismiss(animated: true)
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            onColorPicked(viewController.selectedColor)
            parent.isPresented = false
            viewController.dismiss(animated: true)
        }
    }
}
