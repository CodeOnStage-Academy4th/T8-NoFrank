//
//  HomeView.swift
//  T8-NoFrank
//
//  Created by 나현흠 on 8/8/25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("isAlarmEnabled") private var isEnabled: Bool = false
    @State private var isAnimating: Bool = false
    @State private var isModal: Bool = false
    @State private var Time: String = "00:00"
    @State private var alarmTime = Date()
    @State private var alarmDays: [AlarmSettingView.DayItem] = [
        .init(name: "일", isSelected: false),
        .init(name: "월", isSelected: false),
        .init(name: "화", isSelected: false),
        .init(name: "수", isSelected: false),
        .init(name: "목", isSelected: false),
        .init(name: "금", isSelected: false),
        .init(name: "토", isSelected: false),
    ]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("Home_Background")
            Color.black
                .opacity(0.7)
                .edgesIgnoringSafeArea(.all)

            if isEnabled {
                MovingRockView(isBreakable: false)
            } else {
                Image("RockChain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 455, height: 342)
                    .padding(.top, 65)

            }

            VStack {
                AlarmCard(
                    isOn: $isEnabled,
                    timeText: DateFormatter.localizedString(
                        from: alarmTime,
                        dateStyle: .none,
                        timeStyle: .short
                    ),
                    selectedDays: alarmDays.filter { $0.isSelected }.map {
                        $0.name
                    },
                    date: alarmTime
                ) {
                    isModal.toggle()
                }
                .padding(.top, 131)
                .padding(.horizontal, 130)

                Spacer()
            }
        }
        .frame(width: screenWidth, height: screenHeight)
        .onAppear {
            loadAlarm()
            NotificationService.requestAuthorization()
        }
        .sheet(isPresented: $isModal) {
            NavigationStack {
                AlarmSettingView(
                    isAlarmEnabled: isEnabled,
                    time: $alarmTime,
                    days: $alarmDays  // 🔥 추가
                )
                .navigationTitle("알람 편집")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color(hex: "151515"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("취소")
                            .foregroundStyle(Color(hex: "#BE5F1B"))
                    }
                }
            }
            .presentationDetents([.fraction(0.6), .medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: isModal) { newValue in
            if newValue == false {
                persistAlarm()
            }
        }
        .onChange(of: isEnabled) { newValue in

            UserDefaults.standard.set(alarmTime, forKey: "alarmTime")
            let comps = Calendar.current.dateComponents(
                [.hour, .minute],
                from: alarmTime
            )
            let hour = comps.hour ?? -1
            let minute = comps.minute ?? -1
            if comps.hour != nil && comps.minute != nil {
                UserDefaults.standard.set(hour, forKey: "alarmHour")
                UserDefaults.standard.set(minute, forKey: "alarmMinute")
            }
            let selectedNames = alarmDays.filter { $0.isSelected }.map {
                $0.name
            }
            UserDefaults.standard.set(
                selectedNames,
                forKey: "alarmSelectedDays"
            )

            let weekdays: Set<Int> = Set(
                alarmDays.enumerated().compactMap { index, day in
                    day.isSelected ? index + 1 : nil
                }
            )

            if newValue == false {
                AlarmCancelService.cancelWeeklyBurstAll(
                    weekdays: weekdays,
                    hour: hour,
                    minute: minute,
                    second: 0,
                    totalCount: 8
                )
                print("모든 노티 삭제")
            } else {
                NotificationService.cancelWeeklyBurst(
                    weekdays: weekdays,
                    hour: hour,
                    minute: minute,
                    second: 0
                )
                NotificationService.scheduleWeeklyBurst(
                    weekdays: weekdays,
                    hour: hour,
                    minute: minute,
                    second: 0,
                    intervalSec: 30,  // 30초 간격
                    count: 8  // 8개의 노티
                )
                print("노티 추가됨")
            }
        }
    }

    private func persistAlarm() {
        UserDefaults.standard.set(alarmTime, forKey: "alarmTime")
        let comps = Calendar.current.dateComponents(
            [.hour, .minute],
            from: alarmTime
        )
        let hour = comps.hour ?? -1
        let minute = comps.minute ?? -1
        if comps.hour != nil && comps.minute != nil {
            UserDefaults.standard.set(hour, forKey: "alarmHour")
            UserDefaults.standard.set(minute, forKey: "alarmMinute")
        }
        let selectedNames = alarmDays.filter { $0.isSelected }.map { $0.name }
        UserDefaults.standard.set(selectedNames, forKey: "alarmSelectedDays")

        print(
            "[Alarm][persist] time=\(alarmTime) (hour=\(hour), minute=\(minute))"
        )
        print("[Alarm][persist] days=\(selectedNames)")

        if isEnabled {
            let weekdays: Set<Int> = Set(
                alarmDays.enumerated().compactMap { index, day in
                    day.isSelected ? index + 1 : nil
                }
            )
            // 기존 매주 반복 노티 취소
            NotificationService.cancelWeeklyBurst(
                weekdays: weekdays,
                hour: hour,
                minute: minute,
                second: 0
            )

            // 새로운 매주 반복 노티 스케줄링
            NotificationService.scheduleWeeklyBurst(
                weekdays: weekdays,
                hour: hour,
                minute: minute,
                second: 0,
                intervalSec: 30,
                count: 8
            )
            print("매주 반복 노티 재설정 완료")
        } else {
            // 알람이 비활성화되면 모든 매주 반복 노티 취소
            let allWeekdays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]
            NotificationService.cancelWeeklyBurst(
                weekdays: allWeekdays,
                hour: hour,
                minute: minute,
                second: 0
            )
        }
    }

    private func loadAlarm() {
        if let hour = UserDefaults.standard.object(forKey: "alarmHour") as? Int,
            let minute = UserDefaults.standard.object(forKey: "alarmMinute")
                as? Int
        {
            var comps = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: Date()
            )
            comps.hour = hour
            comps.minute = minute
            if let rebuilt = Calendar.current.date(from: comps) {
                alarmTime = rebuilt
            }
        } else if let savedTime = UserDefaults.standard.object(
            forKey: "alarmTime"
        ) as? Date {
            // Fallback for older saved value
            alarmTime = savedTime
        }
        print("[Alarm][load] time=\(alarmTime)")

        if let names = UserDefaults.standard.stringArray(
            forKey: "alarmSelectedDays"
        ) {
            for i in alarmDays.indices {
                alarmDays[i].isSelected = names.contains(alarmDays[i].name)
            }
            print("[Alarm][load] days=\(names)")
        }

        // 앱 시작 시 매주 반복 노티 복원
        if isEnabled {
            let comps = Calendar.current.dateComponents(
                [.hour, .minute],
                from: alarmTime
            )
            let hour = comps.hour ?? 0
            let minute = comps.minute ?? 0

            let weekdays: Set<Int> = Set(
                alarmDays.enumerated().compactMap { index, day in
                    day.isSelected ? index + 1 : nil
                }
            )

            NotificationService.scheduleWeeklyBurst(
                weekdays: weekdays,
                hour: hour,
                minute: minute,
                second: 0,
                intervalSec: 30,
                count: 8
            )
            print("앱 시작 시 매주 반복 노티 복원 완료")
        }
    }
}

#Preview {
    HomeView()
}

struct AlarmCard: View {
    @Binding var isOn: Bool
    var timeText: String
    var selectedDays: [String]
    var date: Date
    var onTap: () -> Void

    private let days: [String] = ["일", "월", "화", "수", "목", "금", "토"]

    var amPm: String {
        let hour = Calendar.current.component(.hour, from: date)
        return hour < 12 ? "오전" : "오후"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.black.opacity(0.48))

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        ForEach(days.indices, id: \.self) { idx in
                            let label = days[idx]
                            Text(label)
                                .font(.headline)
                                .fontWeight(
                                    selectedDays.contains(label)
                                        ? .semibold : .regular
                                )
                                .foregroundStyle(
                                    selectedDays.contains(label)
                                        ? Color(hex: "#BE5F1B")
                                        : Color.white.opacity(0.7)
                                )
                        }
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(amPm)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .opacity(0.9)

                        Text(timeText.isEmpty ? "07:00" : timeText)
                            .font(
                                .system(
                                    size: 30,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)
                    }
                }

                Spacer(minLength: 16)

                CustomToggle(isOn: $isOn)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 109)
        .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .onTapGesture { onTap() }
    }
}
