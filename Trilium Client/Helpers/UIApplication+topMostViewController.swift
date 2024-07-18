//
//  UIApplication+topMostViewController.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/07/19.
//

import UIKit

extension UIApplication {
    class func topMostViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.rootViewController?.topMostViewController()
    }
}
