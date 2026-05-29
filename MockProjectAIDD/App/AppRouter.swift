// AppRouter.swift
// MockProjectAIDD

import Combine
import SwiftUI

enum AppRoute: Hashable {
    case login
    case home
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var currentRoute: AppRoute = .login

    func navigate(to route: AppRoute) {
        currentRoute = route
    }
}
