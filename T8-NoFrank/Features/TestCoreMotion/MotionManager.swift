import CoreMotion
import Foundation

final class MotionManager {
    let shakeDegreesStream: AsyncStream<Int>

    private var shakeDegreesContinuation: AsyncStream<Int>.Continuation?
    
    private var shakeCooldown: TimeInterval
    private var _lastShakeAt: Date  // .now()랑 coolDown만큼 차이나는지 비교되는지 변수

    private var stopTimeout: TimeInterval
    private var startThreshold: Double
    private var stopThreshold: Double

    static let shared = MotionManager()

    private let motionManager = CMMotionManager()

    private init() {
        var cont: AsyncStream<Int>.Continuation!
        self.shakeDegreesStream = AsyncStream<Int>(
            bufferingPolicy: .bufferingNewest(1)
        ) { c in
            cont = c
        }
        self.shakeDegreesContinuation = cont

        self.shakeCooldown = 0.1
        self._lastShakeAt = .distantPast
        self.stopTimeout = 0.25
        self.startThreshold = 2.0
        self.stopThreshold = 1.2
    }

    func start(
        updateInterval: TimeInterval = 1.0 / 60.0,
        referenceFrame: CMAttitudeReferenceFrame = .xArbitraryZVertical,
        startThreshold: Double = 2.0,
        stopThreshold: Double = 1.2,
        stopTimeout: TimeInterval = 0.25,
        cooldown: TimeInterval = 0.1
    ) {
        self.startThreshold = startThreshold
        self.stopThreshold = stopThreshold
        self.stopTimeout = stopTimeout
        self.shakeCooldown = cooldown

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

    private func handleShakeDetection(
        from accel: CMAcceleration
    ) {
        let now = Date()

        let ax = accel.x
        let ay = accel.y
        let magnitude = sqrt(ax * ax + ay * ay)

        // If above start threshold and cooldown has passed, treat as an active shake sample
        if magnitude >= startThreshold, now.timeIntervalSince(_lastShakeAt) >= shakeCooldown {
            let degrees = (Int((atan2(ay, ax) * -180.0 / .pi).rounded()) + 270) % 360

            shakeDegreesContinuation?.yield(degrees)
            _lastShakeAt = now
            return
        }
    }

    deinit {
        shakeDegreesContinuation?.finish()
        stopAll()
    }
}
