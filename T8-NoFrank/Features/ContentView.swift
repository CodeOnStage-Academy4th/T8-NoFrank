//
//  ContentView.swift
//  T8-NoFrank
//
//  Created by 이주현 on 8/7/25.
//

import SwiftUI

struct LobbyView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("This is LobbyView")
            Button {
                router.currentScreen = .sub
            } label: {
                Text("Go to SubView")
            }

        }
        .padding()
    }
}

#Preview {
    LobbyView()
}
