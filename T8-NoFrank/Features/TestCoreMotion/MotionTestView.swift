//
//  MotionTestView.swift
//  T8-NoFrank
//
//  Created by SeanCho on 8/8/25.
//

import SwiftUI
import UIKit

struct MotionTestView: View {
    private let shakeManager = MotionManager.shared
    private let rockWidth: CGFloat = 230
    private let rockHeight: CGFloat = 233
    @State private var containerSize: CGSize = .zero
    @State private var rockOffset: CGSize = .zero
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ZStack {
                    Color.clear
                    Image(.rockDefault)
                        .resizable()
                        .scaledToFit()
                        .frame(width: rockWidth, height: rockHeight)
                        .offset(rockOffset)
                        .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                }
                .onAppear { containerSize = proxy.size }
                .onChange(of: proxy.size) {
                    containerSize = proxy.size
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            shakeManager.start(updateInterval: 1.0 / 60.0, startThreshold: 2.0, stopThreshold: 0.6, stopTimeout: 0.25, cooldown: 0.1)
            for await deg in shakeManager.shakeDegreesStream {
                await handleShakeDegree(deg)
            }
        }
        .onDisappear { shakeManager.stopAll() }
    }
    
    private func handleShakeDegree(_ deg: Int) async {
        guard containerSize != .zero else { return }
        
        let theta = CGFloat(Double(deg) * .pi / 180)
        let ux = sin(theta)
        let uy = -cos(theta)
        
        let halfW = containerSize.width / 2
        let halfH = containerSize.height / 2
        let xMargin = max(halfW - rockWidth / 2, 0)
        let yMargin = max(halfH - rockHeight / 2, 0)
        
        let tx = ux == 0 ? .infinity : xMargin / abs(ux)
        let ty = uy == 0 ? .infinity : yMargin / abs(uy)
        let t = min(tx, ty)
        
        let dx = ux * t
        let dy = uy * t
        
        withAnimation(.easeOut(duration: 0.1)) {
            rockOffset = CGSize(width: dx, height: dy)
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        try? await Task.sleep(for: .seconds(0.1))
    }
}
