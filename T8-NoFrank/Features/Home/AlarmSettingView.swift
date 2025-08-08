//
//  AlarmSettingView.swift
//  T8-NoFrank
//
//  Created by 나현흠 on 8/8/25.
//

import SwiftUI

struct AlarmSettingView: View {
    
    struct DayItem: Identifiable {
        let name: String
        var isSelected: Bool
        var id: String { name }
    }
    
    @Binding var time: Date
    @Binding var days: [DayItem]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            ZStack(alignment: .top) {
                Color(hex: "151515").edgesIgnoringSafeArea(.all)
                VStack{
                    DatePicker("",
                               selection: $time,
                               displayedComponents: [.hourAndMinute]
                    )
                    .padding(.horizontal, 0)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: Locale.preferredLanguages.first ?? "ko"))
                    .colorScheme(.dark)
                    
                    VStack{
                        Text("요일")
                            .multilineTextAlignment(.leading)
                        HStack {
                            ForEach($days, id: \.name) { $day in
                                DatePickButton(title: day.name, isSelected: $day.isSelected)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("취소")
                        .foregroundStyle(Color(hex: "#BE5F1B"))
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("저장")
                        .foregroundStyle(Color(hex: "#BE5F1B"))
                })
            }
        }
    }
}

#Preview {
    HomeView()
}
