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
        .init(name: "토", isSelected: false)
    ]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            ZStack{
                Image("Home_Background")
                Color.black
                    .opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    AlarmCard(isOn: $isEnabled, timeText: timeTextFormatted, selectedDays: alarmDays.filter { $0.isSelected }.map { $0.name }, date: alarmTime) {
                        isModal.toggle()
                    }
                    .padding(.top, 131)
                    .padding(.horizontal, 130)
                    
                    if isEnabled {
                        Image("RockDefault")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 189, height: 230)
                            .padding(.top, 119)
                    } else {
                        Image("RockChain")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 455, height: 342)
                            .padding(.top, 65)
                        
                    }
                    Spacer()
                }
            }
        }
        .onAppear { loadAlarm() }
        .sheet(isPresented: $isModal) {
            NavigationStack {
                AlarmSettingView(time: $alarmTime, days: $alarmDays)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("알람 편집")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.white)
                                .padding(.vertical, 30)
                        }
                    }
                    .toolbarBackground(Color(hex: "151515"), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(.hidden, for: .navigationBar)
            }
            .presentationDetents([.fraction(0.6)])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: isModal) { newValue in
            if newValue == false {
                persistAlarm()
            }
        }
    }
    
    private var timeTextFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: alarmTime)
    }
    
    private func persistAlarm() {
        UserDefaults.standard.set(alarmTime, forKey: "alarmTime")
        let comps = Calendar.current.dateComponents([.hour, .minute], from: alarmTime)
        let hour = comps.hour ?? -1
        let minute = comps.minute ?? -1
        if comps.hour != nil && comps.minute != nil {
            UserDefaults.standard.set(hour, forKey: "alarmHour")
            UserDefaults.standard.set(minute, forKey: "alarmMinute")
        }
        let selectedNames = alarmDays.filter { $0.isSelected }.map { $0.name }
        UserDefaults.standard.set(selectedNames, forKey: "alarmSelectedDays")
        
        print("[Alarm][persist] time=\(alarmTime) (hour=\(hour), minute=\(minute))")
        print("[Alarm][persist] days=\(selectedNames)")
    }
        
    private func loadAlarm() {
        if let hour = UserDefaults.standard.object(forKey: "alarmHour") as? Int,
           let minute = UserDefaults.standard.object(forKey: "alarmMinute") as? Int {
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            comps.hour = hour
            comps.minute = minute
            if let rebuilt = Calendar.current.date(from: comps) {
                alarmTime = rebuilt
            }
        } else if let savedTime = UserDefaults.standard.object(forKey: "alarmTime") as? Date {
            alarmTime = savedTime
        }
        print("[Alarm][load] time=\(alarmTime)")
        
        if let names = UserDefaults.standard.stringArray(forKey: "alarmSelectedDays") {
            for i in alarmDays.indices {
                alarmDays[i].isSelected = names.contains(alarmDays[i].name)
            }
            print("[Alarm][load] days=\(names)")
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
    
    private let days: [String] = ["일","월","화","수","목","금","토"]
    
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
                                .fontWeight(selectedDays.contains(label) ? .semibold : .regular)
                                .foregroundStyle(
                                    !selectedDays.contains(label)
                                        ? Color(hex: "#969698")
                                        : (isOn
                                            ? Color(hex: "#BE5F1B")
                                            : Color(hex: "#282828"))
                                )
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(amPm)
                            .font(.title3)
                            .foregroundStyle(isOn ? .white : Color(hex: "#969698"))
                            .opacity(0.9)
                        
                        Text(timeText.isEmpty ? "07:00" : timeText)
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundStyle(isOn ? .white : Color(hex: "#969698"))
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
