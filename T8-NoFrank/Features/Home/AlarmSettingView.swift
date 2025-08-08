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
        DayItem(name: "일요일", isSelected: false),
        DayItem(name: "월요일", isSelected: false),
        DayItem(name: "화요일", isSelected: false),
        DayItem(name: "수요일", isSelected: false),
        DayItem(name: "목요일", isSelected: false),
        DayItem(name: "금요일", isSelected: false),
        DayItem(name: "토요일", isSelected: false)
    ]
    
    var body: some View {
        VStack{
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                VStack{
                    DatePicker(
                        "",
                        selection: $time,
                        displayedComponents: [.hourAndMinute]
                    )
                    .border(Color.gray, width: 1)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    
                    List {
                        ForEach($days) { $day in
                            Toggle(day.name, isOn: $day.isSelected)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.white)
                }
            }
        }
    }
}

#Preview {
    AlarmSettingView()
}
