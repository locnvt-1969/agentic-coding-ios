// AppRouter.swift
// MockProjectAIDD
//
// Single source of truth for navigation.
// `currentRoute` drives the top-level auth gate (login / main app / full-screen error).
// `path` drives in-app push navigation inside the main tab shell.

import Combine
import SwiftUI

/// Top-level full-screen routes (auth gate).
enum AppRoute: Hashable {
    case login
    case home            // renders the main tab shell (Home tab default)
    case error(AppErrorKind)
}

/// Full-screen error kinds mapped from MoMorph error screens.
enum AppErrorKind: Hashable {
    case accessDenied    // 403
    case notFound        // 404
}

/// In-app push destinations within the main tab shell.
enum NavDestination: Hashable {
    case profileSelf
    case profileOther(userId: String)
    case awardDetail(type: AwardType)
    case secretBox
    case kudosBoard
    case allKudos
    case sendKudo
    case viewKudo(id: String)
    case searchSunner
    case communityStandards
    case rules
    case notifications
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var currentRoute: AppRoute = .login
    @Published var path: [NavDestination] = []

    func navigate(to route: AppRoute) {
        currentRoute = route
    }

    func push(_ destination: NavDestination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
