//
//  StoneDustView.swift
//  T8-NoFrank
//
//  Created by JiJooMaeng on 8/8/25.
//

import SwiftUI


struct StoneDustView: View {
    @EnvironmentObject var router: AppRouter
    @State private var blowDetection = BlowDetection()
    @State private var triggerActivated = false
    @State private var dustOffset: CGFloat = 0
    @State private var newStoneOffset: CGFloat = 400
    @State private var newStoneOpacity: Double = 0
    
    var body: some View {
        ZStack {
            if !triggerActivated {
                Text("돌이 깨졌어요")
                    .padding(.bottom, 500)
            }
            
            ZStack {
                Image("stoneDust")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .offset(x: dustOffset)
                    .opacity(1.0 - min(1.0, Double(abs(dustOffset / 300))))

                Image("newStone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .rotationEffect(.degrees(newStoneOffset == 0 ? 0 : 720))
                    .offset(x: newStoneOffset)
                    .opacity(newStoneOpacity)
            }
        }
        .onChange(of: blowDetection.didBlow) { _, didBlow in
            if didBlow && !triggerActivated {
                withAnimation(.easeIn(duration: 1.0)) {
                    dustOffset = -400
                }
                withAnimation(.easeOut(duration: 1.0)) {
                    newStoneOffset = 0
                    newStoneOpacity = 1
                }
                triggerActivated = true
                blowDetection.stop()
                // 메인으로 이동
                //DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                //    router.currentScreen = .lobby
                //}
            }
        }
        .onDisappear {
            blowDetection.stop()
        }

        .onAppear {
            triggerActivated = false
            dustOffset = 0
            newStoneOffset = 400
            newStoneOpacity = 0
            blowDetection.start()
        }
    }
}

#Preview {
    StoneDustView()
}
