//
//  BlowDetection.swift
//  T8-NoFrank
//
//  Created by JiJooMaeng on 8/8/25.
//


import Foundation
import AVFoundation

@Observable
final class BlowDetection {
    private var recorder: AVAudioRecorder?
    private var timer: Timer?

    var didBlow: Bool = false

    func start() {
//        print("호출")
        let url = URL(fileURLWithPath: "/dev/null")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.isMeteringEnabled = true
            recorder?.record()
            let started = recorder?.record() ?? false
            print("🎙️ record() 시작됨?: \(started)")

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.recorder?.updateMeters()
                let db = self.recorder?.peakPower(forChannel: 0) ?? -160
                print("실시간 데시벨 :\(db)")
                if db > -100 {
                    Task { @MainActor in
                        print("blow (db: \(db))")
                        self.didBlow = true
                    }
                }
            }
        } catch {
            print("녹음기 오류: \(error.localizedDescription)")
        }
    }

    func stop() {
        timer?.invalidate()
        recorder?.stop()
    }
}
