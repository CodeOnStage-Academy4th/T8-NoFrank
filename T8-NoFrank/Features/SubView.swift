//
//  SubView.swift
//  T8-NoFrank
//
//  Created by 이주현 on 8/7/25.
//

import SwiftUI

struct SubView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("This is SubView")
            Button {
                router.currentScreen = .lobby
            } label: {
                Text("Back to LobbyView")
            }
        }
        .padding()
    }
}

#Preview {
    SubView()
}
