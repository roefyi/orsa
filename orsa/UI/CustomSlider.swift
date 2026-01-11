//
//  CustomSlider.swift
//  orsa
//
//  Created on 1/9/26.
//

import SwiftUI

struct CustomSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let suffix: String?
    
    @State private var isDragging = false
    
    init(title: String, value: Binding<Double>, in range: ClosedRange<Double>, step: Double = 1, suffix: String? = nil) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.suffix = suffix
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track (entire element) - lighter for unfilled portion
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primaryText.opacity(0.1))
                    .frame(height: 44)
                
                // Progress indicator (filled portion extends to/past thumb, thumb overlays it)
                let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
                let thumbWidth: CGFloat = 52
                let trackWidth = geometry.size.width
                let thumbCenter = thumbWidth/2 + (trackWidth - thumbWidth) * progress
                
                // Fill extends to thumb center (darker) - creates seamless look when thumb overlays
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primaryText.opacity(0.25))
                    .frame(width: max(0, thumbCenter + thumbWidth/2), height: 44)
                
                // Text content inside slider
                HStack {
                    // Title on the left
                    Text(title)
                        .font(.oscineBody)
                        .foregroundColor(.primaryText.opacity(0.7))
                        .padding(.leading, 12)
                    
                    Spacer()
                    
                    // Value on the right
                    Text(formatValue(value) + (suffix ?? ""))
                        .font(.oscineBody)
                        .foregroundColor(.primaryText)
                        .padding(.trailing, 12)
                }
                .frame(height: 44)
                
                // Thumb (draggable handle) - overlays the fill seamlessly, matches element height
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primaryText.opacity(0.8))
                    .frame(width: thumbWidth, height: 44)
                    .scaleEffect(isDragging ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
                    .position(
                        x: thumbCenter,
                        y: 22
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                isDragging = true
                                // Allow thumb to reach from start (thumbWidth/2) to end (width - thumbWidth/2)
                                let trackStart = thumbWidth/2
                                let trackEnd = geometry.size.width - thumbWidth/2
                                let position = max(trackStart, min(gesture.location.x, trackEnd))
                                let percentage = (position - trackStart) / (trackEnd - trackStart)
                                var newValue = range.lowerBound + (Double(percentage) * (range.upperBound - range.lowerBound))
                                newValue = round(newValue / step) * step
                                value = min(max(newValue, range.lowerBound), range.upperBound)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
            .frame(height: 44)
        }
        .frame(height: 44)
    }
    
    private func formatValue(_ value: Double) -> String {
        if step >= 1.0 {
            return "\(Int(value))"
        } else if step >= 0.1 {
            return String(format: "%.1f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
}

// Convenience initializer without title for backward compatibility
extension CustomSlider {
    init(value: Binding<Double>, in range: ClosedRange<Double>, step: Double = 1) {
        self.title = ""
        self._value = value
        self.range = range
        self.step = step
        self.suffix = nil
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var delay: Double = 0.0
        @State private var duration: Double = 0.50
        
        var body: some View {
            VStack(spacing: 20) {
                CustomSlider(
                    title: "Delay",
                    value: $delay,
                    in: 0.0...2.0,
                    step: 0.01
                )
                
                CustomSlider(
                    title: "Time",
                    value: $duration,
                    in: 15.0...75.0,
                    step: 1.0,
                    suffix: "s"
                )
            }
            .padding()
            .background(Color.appBackground)
        }
    }
    
    return PreviewWrapper()
}
