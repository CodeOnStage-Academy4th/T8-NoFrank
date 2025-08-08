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
            ZStack{
                Image("Home_Background")
                Color.black
                    .opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Button("임시 토글") {
                        isEnabled.toggle()
                    }
                    .padding(.top, 100)
                    
                    ZStack(alignment: .center) {
                        Button {
                            isModal.toggle()
                        } label: {
                            VStack(spacing: 0){
                                Text("일 월 화 수 목 금 토")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding()
                                Text("오전 \(Time)")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 10)
                            }
                        }
                        .frame(width: 260, height: 144)
                        .background(.black.opacity(0.48))
                        .cornerRadius(30)
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    if isEnabled {
                        Image("RockDefault")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 270, height: 270)
                            .padding(.bottom, 250)
                    } else {
                        Image("Rock_Default")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 270, height: 270)
                            .padding(.bottom, 250)
                    }
                }
            }
        }
        .sheet(isPresented: $isModal) {
            NavigationStack {
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
}

#Preview {
    HomeView()
}
