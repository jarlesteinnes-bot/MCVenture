//
//  LogoView.swift
//  MCVenture
//
//  Created by BNTF on 22/11/2025.
//

import SwiftUI

struct LogoView: View {
    var size: CGFloat = 300
    var showText: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            let dynamicSize = min(size, geometry.size.width * 0.7, geometry.size.height * 0.5)
            
            makeContent(size: dynamicSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: size * 1.3)
    }
    
    @ViewBuilder
    private func makeContent(size: CGFloat) -> some View {
        VStack(spacing: min(20, size * 0.067)) {
            // Motorcycle icon with speed effect
            ZStack {
                // Motion blur effect behind
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: "figure.motorcycling")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.5)
                        .foregroundStyle(.white.opacity(Double(5-i) * 0.05))
                        .offset(x: CGFloat(i) * -8, y: 0)
                        .blur(radius: CGFloat(i) * 2)
                }
                
                // Main icon
                Image(systemName: "figure.motorcycling")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.5)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.8), radius: 25, x: 0, y: 0)
                    .shadow(color: .red.opacity(0.6), radius: 15, x: 0, y: 0)
                    .shadow(color: .black, radius: 10, x: 5, y: 5)
            }
            
            if showText {
                VStack(spacing: min(8, size * 0.027)) {
                    // Main title with italics for speed
                    HStack(spacing: min(4, size * 0.012)) {
                        Text("MC")
                            .font(.system(size: min(50, size * 0.17), weight: .black, design: .default))
                            .italic()
                            .kerning(2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .orange.opacity(0.8), radius: 20, x: 0, y: 0)
                            .shadow(color: .red.opacity(0.5), radius: 10, x: 3, y: 3)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        Text("VENTURES")
                            .font(.system(size: min(50, size * 0.17), weight: .heavy, design: .default))
                            .kerning(3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .white.opacity(0.8), radius: 15, x: 0, y: 0)
                    }
                    
                    // Subtitle with motion
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .orange, .red, .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2)
                            .frame(maxWidth: 40)
                        
                        Text("RIDE YOUR ADVENTURE")
                            .font(.system(size: min(13, size * 0.043), weight: .bold, design: .default))
                            .kerning(2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .red, .orange, .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2)
                            .frame(maxWidth: 40)
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        LogoView()
    }
}
