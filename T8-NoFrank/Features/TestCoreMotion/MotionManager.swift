import CoreMotion
import Foundation

final class MotionManager {
    static let shared = MotionManager()
    let degreesStream: AsyncStream<Int>

    private let motionManager = CMMotionManager()

    private var degreesContinuation: AsyncStream<Int>.Continuation?
    
    private var shakeCooldown: TimeInterval = 0.35
    private var _lastShakeAt: Date = .distantPast  // .now()랑 coolDown만큼 차이나는지 비교되는 변수

    private init() {
        var cont: AsyncStream<Int>.Continuation!
        self.degreesStream = AsyncStream<Int>(
            bufferingPolicy: .bufferingNewest(1)
        ) { c in
            cont = c
        }
        self.degreesContinuation = cont
    }

    func start(
        updateInterval: TimeInterval = 1.0 / 60.0,
        referenceFrame: CMAttitudeReferenceFrame = .xArbitraryZVertical,
        shakeThreshold: Double = 2.0
    ) {
        stopAll()

        motionManager.deviceMotionUpdateInterval = updateInterval

        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.startDeviceMotionUpdates(using: referenceFrame, to: .main)
        { [weak self] data, error in
            if let data {
                self?.handleShakeDetection(
                    from: data.userAcceleration,
                    threshold: shakeThreshold
                )
            }
        }
    }

    func stopAll() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    private func handleShakeDetection(
        from accel: CMAcceleration,
        threshold: Double
    ) {
        let now = Date()
        guard now.timeIntervalSince(_lastShakeAt) >= shakeCooldown else {
            return
        }
        
        let ax = accel.x
        let ay = accel.y

        let magnitude = sqrt(ax * ax + ay * ay)
        guard magnitude >= threshold else { return }

        let degrees =
            (Int((atan2(ay, ax) * -180.0 / .pi).rounded()) + 270) % 360

        _lastShakeAt = now
        degreesContinuation?.yield(degrees)
    }

    deinit {
        degreesContinuation?.finish()
        stopAll()
    }
}
