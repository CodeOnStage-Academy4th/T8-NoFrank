//
//  HomeView.swift
//  T8-NoFrank
//
//  Created by 나현흠 on 8/8/25.
//

import SwiftUI

struct HomeView: View {
    @State private var isEnabled: Bool = false
    @State private var isAnimating: Bool = false
    @State private var isModal: Bool = false
    @State private var Time: String = "00:00"
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                Button {
                    isModal.toggle()
                } label: {
                    Text(Time)
                        .frame(width: 200, height: 60)
                }
                .background(.white)
                .border(.pink, width: 4)
                .cornerRadius(8)
            }
            .padding(.top, 50)
            
            if isEnabled {
                Button(action: {
                    isEnabled.toggle()
                    isAnimating.toggle()
                }) {
                    Image("Rock_Default")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .animation(.easeInOut(duration: 3), value: isAnimating)
                }
            } else {
                Button {
                    isEnabled.toggle()
                    isAnimating.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                            .animation(.easeInOut(duration: 4), value: isAnimating)
                    }
                }
            }
        }
        .sheet(isPresented: $isModal) {
            AlarmSettingView()
        }
    }
}

#Preview {
    HomeView()
}
