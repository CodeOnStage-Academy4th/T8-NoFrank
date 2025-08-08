//
//  AlarmSettingView.swift
//  T8-NoFrank
//
//  Created by 나현흠 on 8/8/25.
//

import SwiftUI

struct AlarmSettingView: View {
    
    struct DayItem: Identifiable {
        let id = UUID()
        let name: String
        var isSelected: Bool
    }
    
    @State var time: Date = Date()
    @State private var days: [DayItem] = [
        DayItem(name: "일", isSelected: false),
        DayItem(name: "월", isSelected: false),
        DayItem(name: "화", isSelected: false),
        DayItem(name: "수", isSelected: false),
        DayItem(name: "목", isSelected: false),
        DayItem(name: "금", isSelected: false),
        DayItem(name: "토", isSelected: false)
    ]
    
    var body: some View {
        VStack{
            ZStack(alignment: .top) {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack{
                    DatePicker("",
                               selection: $time,
                               displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: Locale.preferredLanguages.first ?? "ko"))
                    .colorScheme(.dark) // 이 뷰 안에서만 다크 톤 강제
                    HStack {
                        ForEach($days) { $day in
                            DatePickButton(title: day.name, isSelected: $day.isSelected)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    HomeView()
}
