//
//  NotificationExtension.swift
//  T8-NoFrank
//
//  Created by 문창재 on 8/9/25.
//

import UserNotifications
import SwiftUI

extension NotificationService {
    
    //MARK: -- 선택한 요일에 요일당 8개의 노티 생성
    static func scheduleWeeklyBurst(weekdays: Set<Int>,
                                    hour: Int, minute: Int, second: Int,
                                    intervalSec: Int, count: Int,
                                    baseKey: String = "WEEKLY_BURST",
                                    title: String = "알람",
                                    body: String = "일어날 시간입니다.",
                                    soundName: String? = nil) {

        let center = UNUserNotificationCenter.current()
        let now = Date()
        let cal = Calendar.current

        for w in weekdays {
            // 1) 다음 발생일 계산 (가장 가까운 w 요일의 지정 시:분:초)
            var match = DateComponents()
            match.weekday = w          // 1=일 ... 7=토
            match.hour = hour
            match.minute = minute
            match.second = second

            guard let base = cal.nextDate(after: now,
                                          matching: match,
                                          matchingPolicy: .nextTime,
                                          direction: .forward) else { continue }

            // 2) 30초 간격 × count개 생성
            for i in 0..<count {
                let fire = base.addingTimeInterval(TimeInterval(intervalSec * i))
                let comps = cal.dateComponents([.year,.month,.day,.hour,.minute,.second], from: fire)

                let content = UNMutableNotificationContent()
                content.title = title
                content.body  = body
                
                // 어떤 사운드 틀지 정하는 곳
                if let name = soundName {
                    content.sound = UNNotificationSound(named: .init(name))
                } else {
                    content.sound = .default
                }
                
                if #available(iOS 15.0, *) {
                    content.interruptionLevel = .timeSensitive
                }

                // 예측 가능한 식별자(요일·시·분·초·인덱스)
                let id = "\(baseKey)_WD\(w)_\(hour)_\(minute)_\(second)_\(i)"

                let trig = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                let req  = UNNotificationRequest(identifier: id, content: content, trigger: trig)
                
                
                center.add(req)
                
            }
        }
    }


    static func cancelWeeklyBurst(weekdays: Set<Int>,
                                  hour: Int, minute: Int, second: Int,
                                  count: Int = 10,
                                  baseKey: String = "WEEKLY_BURST") {
        let ids: [String] = weekdays.flatMap { w in
            (0..<count).map { i in
                "\(baseKey)_WD\(w)_\(hour)_\(minute)_\(second)_\(i)"
            }
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
    }
}

//MARK: -- 노티 배너 누르면 기존에 쌓인 배너도 다 삭제하는 델리게이트
extension NotificationDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        // ✅ 앱이 보낸 알림 전부 제거
        center.removeAllDeliveredNotifications()        // 이미 온 알림 삭제

        // 여기서 알람 화면 전환, 사운드 정지 등 원하는 로직 실행 가능
        print("알림 제거 완료")

        completionHandler()
    }
}
