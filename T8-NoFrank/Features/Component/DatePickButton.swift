//
//  DatePickButton.swift
//  T8-NoFrank
//
//  Created by 나현흠 on 8/9/25.
//

import SwiftUI

struct DatePickButton: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Text(title)
                .font(.system(size: 20))
                .foregroundStyle(Color.white)
        }
        .frame(width: 44, height: 44)
        .background(isSelected ? Color(hex: "#BE5F1B") : Color(hex: "969698"))
        .clipShape(Circle())
    }
}

#Preview {
    AlarmSettingView()
}

#Preview {
    HomeView()
}
