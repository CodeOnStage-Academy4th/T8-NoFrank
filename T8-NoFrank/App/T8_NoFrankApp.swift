//
//  T8_NoFrankApp.swift
//  T8-NoFrank
//
//  Created by 이주현 on 8/7/25.
//

import SwiftUI

@main
struct T8_NoFrankApp: App {
    @StateObject private var router = AppRouter()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup{
            HomeView()
        }
//        WindowGroup {
//            RootView()
//                .environmentObject(router)
//        }
//        .onChange(of: scenePhase) {
//            switch scenePhase {
//            case .background:
//                print("앱이 백그라운드로 전환됨")
//            case .inactive:
//                print("앱이 비활성화됨")
//            case .active:
//                print("앱이 포그라운드 상태")
//            @unknown default:
//                break
//            }
//        }
    }
}

struct RootView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        Group {
            switch router.currentScreen {
            case .lobby: LobbyView()
            case .sub: SubView()
            case .stonedust: StoneDustView()
            }
        }    }
}

#Preview {
    RootView()
        .environmentObject(AppRouter())
}
