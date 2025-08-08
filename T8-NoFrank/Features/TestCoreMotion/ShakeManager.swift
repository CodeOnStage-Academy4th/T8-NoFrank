import CoreMotion
import Foundation

final class ShakeManager {
    static let shared = ShakeManager()
    let degreesStream: AsyncStream<Int>

    private let motionManager = CMMotionManager()

    private var degreesContinuation: AsyncStream<Int>.Continuation?

    private var shakeThreshold: Double = 0.9  // 중력가속도(G)

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
        referenceFrame: CMAttitudeReferenceFrame = .xArbitraryZVertical
    ) {
        stopAll()

        motionManager.deviceMotionUpdateInterval = updateInterval

        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.startDeviceMotionUpdates(using: referenceFrame, to: .main)
        { [weak self] data, error in
            if let data {
                self?.handleShakeDetection(from: data.userAcceleration)
            }
        }
    }

    func stopAll() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    private func handleShakeDetection(from accel: CMAcceleration) {
        let now = Date()
        guard now.timeIntervalSince(_lastShakeAt) >= shakeCooldown else {
            return
        }

        let ax = accel.x
        let ay = accel.y

        let magnitude = sqrt(ax * ax + ay * ay)
        guard magnitude >= shakeThreshold else { return }

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
