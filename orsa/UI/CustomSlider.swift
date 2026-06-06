//
//  CustomSlider.swift
//  orsa
//
//  Created on 1/9/26.
//

import SwiftUI
import UIKit

struct CustomSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let suffix: String?
    
    @State private var textInput = ""
    @State private var isDragging = false
    @State private var selectionGenerator = UISelectionFeedbackGenerator()
    @FocusState private var isValueFieldFocused: Bool
    
    private let rowHeight: CGFloat = 44
    private let columnSpacing: CGFloat = 12
    private let thumbWidth: CGFloat = 28
    
    init(title: String, value: Binding<Double>, in range: ClosedRange<Double>, step: Double = 1, suffix: String? = nil) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.suffix = suffix
    }
    
    var body: some View {
        GeometryReader { geometry in
            let columnWidth = max((geometry.size.width - (columnSpacing * 2)) / 3, 0)
            
            HStack(spacing: columnSpacing) {
                Text(title)
                    .font(.oscineRegular(size: 20))
                    .foregroundColor(.secondaryText)
                    .frame(width: columnWidth, alignment: .leading)
                
                valueBox
                    .frame(width: columnWidth)
                
                sliderControl
                    .frame(width: columnWidth)
            }
        }
        .frame(height: rowHeight)
        .onAppear {
            syncTextFromValue()
        }
        .onChange(of: value) { _, _ in
            guard !isValueFieldFocused else { return }
            syncTextFromValue()
        }
    }
    
    private var valueBox: some View {
        HStack(spacing: 4) {
            TextField("0", text: $textInput)
                .font(.oscineRegular(size: 20))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: true, vertical: false)
                .keyboardType(step >= 1.0 ? .numberPad : .decimalPad)
                .focused($isValueFieldFocused)
                .onSubmit {
                    commitTextInput()
                }
                .onChange(of: isValueFieldFocused) { _, isFocused in
                    if !isFocused {
                        commitTextInput()
                    }
                }
            
            if let suffix {
                Text(suffix)
                    .font(.oscineRegular(size: 20))
                    .foregroundColor(.secondaryText)
                    .fixedSize()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 8)
        .tint(Color(red: 1.0, green: 0.8, blue: 0.0))
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .foregroundColor(.primary)
    }
    
    private var sliderControl: some View {
        GeometryReader { geometry in
            let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let trackWidth = geometry.size.width
            let thumbCenter = thumbWidth / 2 + (trackWidth - thumbWidth) * progress
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
                    .frame(height: rowHeight)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardText.opacity(0.25))
                    .frame(width: max(0, thumbCenter + thumbWidth / 2), height: rowHeight)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.cardText.opacity(0.8))
                    .frame(width: thumbWidth, height: rowHeight)
                    .scaleEffect(isDragging ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
                    .position(x: thumbCenter, y: rowHeight / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                if !isDragging {
                                    selectionGenerator.prepare()
                                }
                                isDragging = true
                                isValueFieldFocused = false
                                let trackStart = thumbWidth / 2
                                let trackEnd = geometry.size.width - thumbWidth / 2
                                let position = max(trackStart, min(gesture.location.x, trackEnd))
                                let percentage = (position - trackStart) / (trackEnd - trackStart)
                                var newValue = range.lowerBound + (Double(percentage) * (range.upperBound - range.lowerBound))
                                newValue = round(newValue / step) * step
                                let clamped = min(max(newValue, range.lowerBound), range.upperBound)
                                if clamped != value {
                                    selectionGenerator.selectionChanged()
                                    selectionGenerator.prepare()
                                }
                                value = clamped
                                syncTextFromValue()
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
        }
        .frame(height: rowHeight)
    }
    
    private func syncTextFromValue() {
        textInput = formatValue(value)
    }
    
    private func commitTextInput() {
        let sanitized = textInput
            .replacingOccurrences(of: ",", with: ".")
            .filter { $0.isNumber || $0 == "." }
        
        guard let parsed = Double(sanitized) else {
            syncTextFromValue()
            return
        }
        
        let stepped = (parsed / step).rounded() * step
        value = min(max(stepped, range.lowerBound), range.upperBound)
        syncTextFromValue()
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
        @State private var yield: Double = 36
        @State private var time: Double = 30
        
        var body: some View {
            VStack(spacing: 12) {
                CustomSlider(
                    title: "Yield",
                    value: $yield,
                    in: 10...110,
                    step: 1,
                    suffix: "g"
                )
                
                CustomSlider(
                    title: "Time",
                    value: $time,
                    in: 15...75,
                    step: 1,
                    suffix: "s"
                )
            }
            .padding()
            .background(Color.appBackground)
        }
    }
    
    return PreviewWrapper()
}
