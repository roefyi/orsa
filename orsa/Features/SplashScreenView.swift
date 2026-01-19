//
//  SplashScreenView.swift
//  orsa
//
//  Created by Rome on 1/15/26.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @Binding var showSplash: Bool
    
    var body: some View {
        if showSplash {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Splash Screen Icon
                    Image("orsasplashscreen")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                }
                .scaleEffect(isActive ? 1.0 : 0.8)
                .opacity(isActive ? 1.0 : 0.0)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    isActive = true
                }
                
                // Dismiss splash after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(showSplash: .constant(true))
}
