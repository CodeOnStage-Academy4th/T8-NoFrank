//
//  C.swift
//  T8-NoFrank
//
//  Created by 이주현 on 8/9/25.
//

import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool
    
    init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }
    
    var body: some View {
        let switchSize = CGSize(width: 52, height: 32)
    
        ZStack(alignment: .top) {
            // 토글 본체
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(isOn ? .orange1 : .gray1)
                .frame(width: switchSize.width, height: switchSize.height)
            // 스위치 위에 살짝 겹치도록 배치
            Text(isOn ? "ON" : "OFF")
                .font(.caption1SemiBold)
                .padding(.top, -14) // 위로 당겨 겹쳐 보이게
                .foregroundStyle(isOn ? .orange1 : .gray1)
                .allowsHitTesting(false) // 터치 방해 X
        }
    }
}

struct CustomToggleExample: View {
    @State var previewIsOn: Bool = false
    
    var body: some View {
        CustomToggle(isOn: $previewIsOn)
    }
}

#Preview {
    CustomToggleExample()
}
