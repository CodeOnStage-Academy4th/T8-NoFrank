//
//  AlarmModel.swift
//  T8-NoFrank
//
//  Created by 나현흠 on 8/8/25.
//

import Foundation

class AlarmModel: Identifiable,ObservableObject {

    let id : UUID = UUID()
    var time: String
    var amPm: String
    var date: Date

    @Published var alarmActive: Bool

    // MARK: CREATE ALARM LIST
    init(date: Date) {

        self.date = date

        alarmActive = true

        let formatter = DateFormatter()

        formatter.dateFormat = "hh:mm"
        time = formatter.string(from: date)

        formatter.dateFormat = "a"
        amPm = formatter.string(from: date)

    }

    // MARK: UPDATE ALARM LIST
    func updateAlarm(date: Date) {

        self.date = date

        alarmActive = true

        let formatter = DateFormatter()

        formatter.dateFormat = "hh:mm"
        time = formatter.string(from: date)

        formatter.dateFormat = "a"
        amPm = formatter.string(from: date)
    }

}
