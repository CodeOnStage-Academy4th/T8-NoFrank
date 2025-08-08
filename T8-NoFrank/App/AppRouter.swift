//
//  AppRouter.swift
//  T8-NoFrank
//
//  Created by 이주현 on 8/7/25.
//

import Foundation
import SwiftUI

enum AppScreen {
    case lobby
    case sub
    case stonedust
}

class AppRouter: ObservableObject {
    @Published var currentScreen: AppScreen = .lobby
}
