//
//  StoneDustView.swift
//  T8-NoFrank
//
//  Created by JiJooMaeng on 8/8/25.
//

import SwiftUI

struct StoneDustView: View {
    var body: some View {
        VStack{
            Text("돌이 깨졌어요")
                .padding(.bottom, 100)
            Image("stoneDust")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
        }
    }
}

#Preview {
    StoneDustView()
}
