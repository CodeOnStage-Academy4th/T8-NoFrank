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
            VStack {
                    if !triggerActivated {
                        Text("돌이 깨졌어요")
                            .font(.body01Bold)
                            .padding(.top, 139)
                    }
                    Spacer()
                }
            
            ZStack {
                VStack {
                    Group {
                        if blowDetection.blowStage == 0 {
                            Image("stoneDust")
                        } else if blowDetection.blowStage == 1 {
                            Image("stoneDustA1")
                            Image("stoneDustA2")
                                .offset(x: dustOffset)
                                .opacity(1.0 - min(1.0, Double(abs(dustOffset / 300))))
                        } else if blowDetection.blowStage == 2 {
                            Image("stoneDustB1")
                            Image("stoneDustB2")
                                .offset(x: dustOffset)
                                .opacity(1.0 - min(1.0, Double(abs(dustOffset / 300))))
                        } else if blowDetection.blowStage == 3 {
                            Image("stoneDustB1")
                                .offset(x: dustOffset)
                                .opacity(1.0 - min(1.0, Double(abs(dustOffset / 300))))
                        }
                    }
                    Spacer()
                }
                .padding(.top, 426)
                
                Image("newStone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .rotationEffect(.degrees(newStoneOffset == 0 ? 0 : 720))
                    .offset(x: newStoneOffset)
                    .opacity(newStoneOpacity)
            }
        }
        .onChange(of: blowDetection.blowStage) { _, stage in
            switch stage {
            case 1:
                withAnimation { dustOffset = -100 }
            case 2:
                withAnimation { dustOffset = -200 }
            case 3:
                withAnimation {
                    dustOffset = -400
                    newStoneOffset = 0
                    newStoneOpacity = 1
                    triggerActivated = true
                }
                blowDetection.stop()
            default:
                break
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
