////
////  MotionTestView.swift
////  T8-NoFrank
////
////  Created by SeanCho on 8/8/25.
////

import SwiftUI
import UIKit
import QuartzCore

struct MovingRockView: View {
    @State var isBreakable: Bool
    
    private let shakeManager = MotionManager.shared
    private var rockWidth: CGFloat {
        switch rockPhase {
        case 0: return 188.95
        case 1: return 187.32
        case 2: return 177.82
        case 3: return 163.5
        case 4: return 153.5
        case 5: return 128.5
        default: return 188.95
        }
    }
    
    private var rockHeight: CGFloat {
        switch rockPhase {
        case 0: return 230
        case 1: return 220.26
        case 2: return 195.31
        case 3: return 178
        case 4: return 175.5
        case 5: return 123.5
        default: return 230
        }
    }
    
    @State private var containerSize: CGSize = .zero
    @State private var rockOffset: CGSize = .zero
    @State private var isShaking: Bool = false
    @State private var velocity: CGVector = .zero
    @State private var tiltAccel: CGVector = .zero
    @State private var physicsTask: Task<Void, Never>? = nil
    
    private var rockImageName: String {
        "Rock\(rockPhase)\(isRockPain ? "Pain" : "")"
    }
    @State private var rockPhase: Int = 0
    @State private var rockPhaseCount: Int = 0
    @State private var isRockPain: Bool = false
    @State private var isRockPainTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ZStack {
                    Color.clear
                    Image(rockImageName)
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
        .overlay {
            ZStack {
                Image("TumbleWeedLayer")
                    .resizable()
                    .scaledToFill()
                    .opacity(!isBreakable ? 1 : 0)
                Image("DustLayer1")
                    .resizable()
                    .scaledToFill()
                    .opacity(rockPhase > 0 ? 1 : 0)
                Image("DustLayer2")
                    .resizable()
                    .scaledToFill()
                    .opacity(rockPhase > 2 ? 1 : 0)
                Image("DustLayer3")
                    .resizable()
                    .scaledToFill()
                    .opacity(rockPhase > 4 ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            shakeManager.start()
            Task {
                for await deg in shakeManager.shakeDegreesStream {
                    await handleShakeDegree(deg)
                }
            }
            
            Task {
                for await vec in shakeManager.tiltUnitStream {
                    await handleTiltVector(vec)
                }
            }
            physicsTask = Task { await runPhysicsLoop() }
        }
        .onDisappear { physicsTask?.cancel(); shakeManager.stopAll() }
    }
    
    private func handleShakeDegree(_ deg: Int) async {
        guard containerSize != .zero else { return }
        
        if isBreakable { isRockPain = true }
        isRockPainTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            isRockPainTask?.cancel()
            isRockPain = false
        }
        isShaking = true
        
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
        
        velocity = .zero
        withAnimation(.easeOut(duration: 0.1)) {
            rockOffset = CGSize(width: dx, height: dy)
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        try? await Task.sleep(for: .seconds(0.1))
        
        if isBreakable {
            rockPhaseCount += 1
            if rockPhaseCount > 5 {
                if rockPhase == 5 {
                    rockPhase = 0
                    rockPhaseCount = 0
                    // 이때 알람꺼지면서 화면 전환
                    AppRouter.shared.navigate(.stonedust)
                } else {
                    rockPhase += 1
                    rockPhaseCount = 0
                }
            }
        }
        
        isShaking = false
    }
    
    private func handleTiltVector(_ vec: CGVector) async {
        guard !isShaking else { return }
        guard containerSize != .zero else { return }

        let deadzone: CGFloat = 0.02
        let ux = abs(vec.dx) < deadzone ? 0 : CGFloat(vec.dx)
        let uy = abs(vec.dy) < deadzone ? 0 : CGFloat(vec.dy)

        let smoothing: CGFloat = 0.15
        tiltAccel.dx = tiltAccel.dx * (1 - smoothing) + ux * smoothing
        tiltAccel.dy = tiltAccel.dy * (1 - smoothing) + uy * smoothing
    }


    private func runPhysicsLoop() async {
        var last = CACurrentMediaTime()
        while !Task.isCancelled {
            let now = CACurrentMediaTime()
            let dt = now - last
            last = now

            await MainActor.run {
                physicsStep(dt: dt)
            }

            try? await Task.sleep(for: .milliseconds(16))
        }
    }

    private func physicsStep(dt: Double) {
        guard containerSize != .zero else { return }
        if isShaking {
            velocity = .zero
            return
        }

        let halfW = containerSize.width / 2
        let halfH = containerSize.height / 2
        let xMargin = max(halfW - rockWidth / 2, 0)
        let yMargin = max(halfH - rockHeight / 2, 0)

        let accelPerG: CGFloat = 2000
        let dampingPerSecond: Double = 3.0
        let restitution: CGFloat = 0.35

        let ax = tiltAccel.dx * accelPerG
        let ay = tiltAccel.dy * accelPerG
        velocity.dx += ax * CGFloat(dt)
        velocity.dy += ay * CGFloat(dt)

        let damping = CGFloat(exp(-dampingPerSecond * dt))
        velocity.dx *= damping
        velocity.dy *= damping

        var px = rockOffset.width + velocity.dx * CGFloat(dt)
        var py = rockOffset.height + velocity.dy * CGFloat(dt)

        if px < -xMargin {
            px = -xMargin
            if velocity.dx < 0 { velocity.dx = -velocity.dx * restitution }
        } else if px > xMargin {
            px = xMargin
            if velocity.dx > 0 { velocity.dx = -velocity.dx * restitution }
        }

        if py < -yMargin {
            py = -yMargin
            if velocity.dy < 0 { velocity.dy = -velocity.dy * restitution }
        } else if py > yMargin {
            py = yMargin
            if velocity.dy > 0 { velocity.dy = -velocity.dy * restitution }
        }

        rockOffset = CGSize(width: px, height: py)
    }
}
