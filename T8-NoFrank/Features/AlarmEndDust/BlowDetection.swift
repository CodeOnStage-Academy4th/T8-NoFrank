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
    private var blowStartTime: Date?

    var didBlow: Bool = false

    func start() {
        stop()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("설정 실패: \(error)")
        }

        let url = URL(fileURLWithPath: "/dev/null")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            if let recorder = recorder {
                recorder.isMeteringEnabled = true
                _ = recorder.record()
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                    guard let self, let recorder = self.recorder else { return }
                    recorder.updateMeters()
                    let db = recorder.peakPower(forChannel: 0)
//                    print("실시간 데시벨: \(db)")
                    if db > -10 {
                        if self.blowStartTime == nil {
                            self.blowStartTime = Date()
                        } else if Date().timeIntervalSince(self.blowStartTime!) > 3 {
                            self.didBlow = true
                        }
                    } else {
                        self.blowStartTime = nil
                    }
                }
            }
        } catch {
            print("오류: \(error.localizedDescription)")
        }
    }

    func stop() {
        timer?.invalidate()
        recorder?.stop()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
