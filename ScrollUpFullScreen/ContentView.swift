//
//  ContentView.swift
//  ScrollUpFullScreen
//
//  Created by Linardos Paschopoulos  on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    let colorsAndImages: [(color: Color, systemImage: String)] = [
        (.red, "star.fill"),
        (.green, "heart.fill"),
        (.blue, "moon.fill"),
        (.yellow, "sun.max.fill"),
        (.purple, "cloud.fill"),
        (.orange, "bolt.fill")
    ]
    
    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(0..<colorsAndImages.count, id: \.self) { index in
                            ZStack {
                                colorsAndImages[index].color
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .id(index)
                                
                                Image(systemName: colorsAndImages[index].systemImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(width: geometry.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                dragOffset = value.translation.height
                            }
                            .onEnded { _ in
                                isDragging = false
                                let threshold: CGFloat = 50
                                
                                if dragOffset > threshold && currentIndex > 0 {
                                    currentIndex -= 1
                                } else if dragOffset < -threshold && currentIndex < colorsAndImages.count - 1 {
                                    currentIndex += 1
                                }
                                
                                isAnimating = true
                                withAnimation {
                                    proxy.scrollTo(currentIndex, anchor: .top)
                                }
                                
                                dragOffset = 0
                                
                                // Re-enable interaction once animation is finished.
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isAnimating = false
                                }
                            }
                    )
                }
                .onChange(of: currentIndex) { _ in
                    withAnimation {
                        isAnimating = true
                        proxy.scrollTo(currentIndex, anchor: .top)
                    }
                    
                    // Re-enable interaction after animation finishes.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isAnimating = false
                    }
                }
                .simultaneousGesture(
                    // Disable default scroll behavior to avoid conflicts.
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in }
                        .onEnded { _ in }
                )
                .disabled(isAnimating) // Disable interaction during animation.
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
