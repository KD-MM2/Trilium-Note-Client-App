//
//  ViewRouter.swift
//  Trilium Client
//
//  Created by Cao Thai Duong on 2024/06/27.
//
import Foundation
import SwiftUI


class Router: ObservableObject {
    // Contains the possible destinations in our Router
    enum Route: Codable, Hashable {
        case root
        case setup
        case home
    }
    
    // Used to programatically control our navigation stack
    @Published var path: NavigationPath = NavigationPath()
    
    // Builds the views
    @ViewBuilder func view(for route: Route) -> some View {
        
        switch route {
            case .root:
                GettingStarted()
            case .setup:
                Setup()
            case .home:
                Home()
        }
    }
    
    // Used by views to navigate to another view
    func navigateTo(_ appRoute: Route) {
        
        print("Navigating to: \(appRoute)")
        path.append(appRoute)
        print("Current path: \(path)")

        path.append(appRoute)
    }
    
    // Used to go back to the previous screen
    func navigateBack() {
        path.removeLast()
    }
    
    // Pop to the root screen in our hierarchy
    func popToRoot() {
        path.removeLast(path.count)
    }
}


// View containing the necessary SwiftUI
// code to utilize a NavigationStack for
// navigation accross our views.
struct RouterView<Content: View>: View {
    @StateObject var router: Router = Router()
    // Our root view content
    private let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationDestination(for: Router.Route.self) { route in
                    router.view(for: route)
                }
        }
        .environmentObject(router)
        .onAppear {
                    print("RouterView appeared")
                }
    }
}
