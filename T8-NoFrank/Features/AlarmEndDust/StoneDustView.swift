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
    
    var body: some View {
        VStack {
            if !triggerActivated {
                Text("돌이 깨졌어요")
                    .padding(.bottom, 100)
            }
            
            ZStack {
                if !triggerActivated {
                    Image("stoneDust")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .offset(x: dustOffset)
                }
                
                if triggerActivated {
                    Image("newStone")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .offset(x: newStoneOffset)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.0)) {
                                newStoneOffset = 0
                            }
                        }
                }
            }
        }
        .onChange(of: blowDetection.didBlow) { _, didBlow in
            if didBlow && !triggerActivated {
                withAnimation(.easeIn(duration: 1.0)) {
                    dustOffset = -300
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    triggerActivated = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                        router.currentScreen = .lobby
//                    }
                }
            }
        }
        .onAppear {
            blowDetection.start()
        }
    }
}

#Preview {
    StoneDustView()
}
