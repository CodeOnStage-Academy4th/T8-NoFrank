//
//  TurnOffAlarmView.swift
//  T8-NoFrank
//
//  Created by 문창재 on 8/9/25.
//

import SwiftUI

struct TurnOffAlarmView: View {
    var body: some View {
        VStack {
            ZStack {
                Image("Home_Background")
                Color.black
                    .opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                MovingRockView(isBreakable: true)
            }
        }
    }
}
