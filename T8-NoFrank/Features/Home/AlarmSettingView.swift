//
//  AlarmSettingView.swift
//  T8-NoFrank
//
//  Created by 나현흠 on 8/8/25.
//

import SwiftUI

struct AlarmSettingView: View {
    @State var date: Date = Date()
    
    var body: some View {
        NavigationStack{
            VStack{
                ZStack {
                    Color.brown.edgesIgnoringSafeArea(.all)
                    DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
