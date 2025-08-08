//
//  HomeView.swift
//  T8-NoFrank
//
//  Created by 나현흠 on 8/8/25.
//

import SwiftUI

struct HomeView: View {
    @State private var isEnabled: Bool = false
    @State private var isAnimating: Bool = false
    @State private var isModal: Bool = false
    @State private var Time: String = "00:00"
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            VStack {
                Button("임시 토글") {
                    isEnabled.toggle()
                }
                .padding(.top, 20)
                
                ZStack(alignment: .center) {
                    Button {
                        isModal.toggle()
                    } label: {
                        VStack(spacing: 0){
                            Text("월 화 수 목 금 토 일")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 150, height: 30)
                                .padding()
                            Text("\(Time)")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 250, height: 60)
                                .padding(.vertical, 10)
                        }
                    }
                    .background(.brown)
                    .cornerRadius(10)
                }
                .padding(.top, 30)
                
                Spacer()
                
                if isEnabled {
                    Image("Rock_Default")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 270, height: 270)
                        .padding(.bottom, 200)
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 270, height: 270)
                        .padding(.bottom, 200)
                }
            }
        }
        .sheet(isPresented: $isModal) {
            AlarmSettingView()
                .navigationTitle("알람 편집")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Text("back")
                            }
                        }
        }
    }
}

#Preview {
    HomeView()
}
