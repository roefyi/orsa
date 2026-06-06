//
//  BrewRatingIcon.swift
//  orsa
//

import SwiftUI

// MARK: - List

struct BrewRatingListIcon: View {
    let rating: Int
    
    @ViewBuilder
    var body: some View {
        switch rating {
        case 0:
            BrewRatingSadFace(style: .filled, size: 16)
        case 1:
            Image(systemName: "hand.thumbsdown.fill")
                .brewRatingSymbolStyle()
        case 3:
            BrewRatingNeutralFaceFilled(size: 16)
        case 4:
            Image(systemName: "hand.thumbsup.fill")
                .brewRatingSymbolStyle()
        case 5:
            Image(systemName: "heart.fill")
                .brewRatingSymbolStyle()
        default:
            EmptyView()
        }
    }
}

// MARK: - Picker (unselected outline)

struct BrewRatingSadFaceOutline: View {
    var body: some View {
        BrewRatingSadFace(style: .outline, size: 20)
    }
}

struct BrewRatingNeutralFaceOutline: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary, lineWidth: 2)
                .frame(width: 20, height: 20)
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.primary.opacity(0.6))
                    .frame(width: 2.5, height: 2.5)
                Circle()
                    .fill(Color.primary.opacity(0.6))
                    .frame(width: 2.5, height: 2.5)
            }
            .offset(y: -2)
            Rectangle()
                .fill(Color.primary.opacity(0.6))
                .frame(width: 8, height: 2)
                .offset(y: 4)
        }
    }
}

// MARK: - Picker (animated row)

private enum BrewRatingPickerMotion {
    static let spring = Animation.spring(response: 0.45, dampingFraction: 0.72)
    static let popSpring = Animation.spring(response: 0.3, dampingFraction: 0.55)
    static let settleSpring = Animation.spring(response: 0.38, dampingFraction: 0.82)
    static let popScale: CGFloat = 1.14
    static let popRotation: Double = -10
    static let restingScale: CGFloat = 1
    static let restingRotation: Double = 0
    static let popSettleDelay: Duration = .milliseconds(160)
    static let buttonHeight: CGFloat = 60
    static let columnSpacing: CGFloat = 10
    static let cornerRadius: CGFloat = 12
}

enum BrewRatingPickerOption: Int, CaseIterable, Identifiable {
    case worst = 0
    case down = 1
    case neutral = 3
    case up = 4
    case love = 5
    
    var id: Int { rawValue }
    
    var emoji: String {
        switch self {
        case .worst: return "☹️"
        case .down: return "👎"
        case .neutral: return "😐"
        case .up: return "👍"
        case .love: return "❤️"
        }
    }
    
    @ViewBuilder
    var outline: some View {
        switch self {
        case .worst:
            BrewRatingSadFaceOutline()
        case .down:
            Image(systemName: "hand.thumbsdown")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.secondary)
        case .neutral:
            BrewRatingNeutralFaceOutline()
        case .up:
            Image(systemName: "hand.thumbsup")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.secondary)
        case .love:
            Image(systemName: "heart")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

struct BrewRatingPickerRow: View {
    @Binding var selectedRating: Int?
    @Binding var longPressJustCompleted: Bool
    @Namespace private var ratingHighlight
    
    var body: some View {
        HStack(spacing: BrewRatingPickerMotion.columnSpacing) {
            ForEach(BrewRatingPickerOption.allCases) { option in
                BrewRatingPickerButton(
                    option: option,
                    isSelected: selectedRating == option.rawValue,
                    namespace: ratingHighlight,
                    longPressJustCompleted: $longPressJustCompleted,
                    onSelect: {
                        withAnimation(BrewRatingPickerMotion.spring) {
                            selectedRating = option.rawValue
                        }
                    },
                    onDeselect: {
                        withAnimation(BrewRatingPickerMotion.spring) {
                            selectedRating = nil
                        }
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct BrewRatingPickerButton: View {
    let option: BrewRatingPickerOption
    let isSelected: Bool
    let namespace: Namespace.ID
    @Binding var longPressJustCompleted: Bool
    let onSelect: () -> Void
    let onDeselect: () -> Void
    
    @State private var presentationScale: CGFloat = 1
    @State private var presentationRotation: Double = 0
    @State private var settleTask: Task<Void, Never>?
    
    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: BrewRatingPickerMotion.buttonHeight)
            .overlay {
                ZStack {
                    RoundedRectangle(cornerRadius: BrewRatingPickerMotion.cornerRadius, style: .continuous)
                        .fill(.regularMaterial)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: BrewRatingPickerMotion.cornerRadius, style: .continuous)
                            .fill(AppGradients.shareYellow)
                            .shadow(
                                color: Color(red: 1.0, green: 0.85, blue: 0.0).opacity(0.4),
                                radius: 10,
                                y: 3
                            )
                            .matchedGeometryEffect(id: "ratingHighlight", in: namespace)
                    }
                    
                    ZStack {
                        option.outline
                            .opacity(isSelected ? 0 : 1)
                            .scaleEffect(isSelected ? 0.55 : 1)
                        
                        Text(option.emoji)
                            .font(.system(size: 22))
                            .opacity(isSelected ? 1 : 0)
                            .scaleEffect(isSelected ? 1 : 0.45)
                    }
                    .animation(BrewRatingPickerMotion.spring, value: isSelected)
                }
                .frame(maxWidth: .infinity)
                .frame(height: BrewRatingPickerMotion.buttonHeight)
                .scaleEffect(presentationScale)
                .rotationEffect(.degrees(presentationRotation))
            }
            .zIndex(isSelected ? 1 : 0)
            .contentShape(Rectangle())
            .onAppear {
                syncPresentationToSelection()
            }
            .onChange(of: isSelected) { _, _ in
                syncPresentationToSelection(animated: true)
            }
        .onTapGesture {
            if !longPressJustCompleted && !isSelected {
                HapticFeedback.light()
                onSelect()
            }
            longPressJustCompleted = false
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            if isSelected {
                longPressJustCompleted = true
                HapticFeedback.medium()
                onDeselect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    longPressJustCompleted = false
                }
            }
        }
    }
    
    private func syncPresentationToSelection(animated: Bool = false) {
        settleTask?.cancel()
        settleTask = nil
        
        if !isSelected {
            applyRestingPresentation(animated: animated)
            return
        }
        
        if animated {
            playSelectPopThenSettle()
        } else {
            presentationScale = BrewRatingPickerMotion.restingScale
            presentationRotation = BrewRatingPickerMotion.restingRotation
        }
    }
    
    private func applyRestingPresentation(animated: Bool) {
        if animated {
            withAnimation(BrewRatingPickerMotion.spring) {
                presentationScale = BrewRatingPickerMotion.restingScale
                presentationRotation = BrewRatingPickerMotion.restingRotation
            }
        } else {
            presentationScale = BrewRatingPickerMotion.restingScale
            presentationRotation = BrewRatingPickerMotion.restingRotation
        }
    }
    
    private func playSelectPopThenSettle() {
        withAnimation(BrewRatingPickerMotion.popSpring) {
            presentationScale = BrewRatingPickerMotion.popScale
            presentationRotation = BrewRatingPickerMotion.popRotation
        }
        
        settleTask = Task { @MainActor in
            try? await Task.sleep(for: BrewRatingPickerMotion.popSettleDelay)
            guard !Task.isCancelled, isSelected else { return }
            
            withAnimation(BrewRatingPickerMotion.settleSpring) {
                presentationScale = BrewRatingPickerMotion.restingScale
                presentationRotation = BrewRatingPickerMotion.restingRotation
            }
        }
    }
}

// MARK: - Sad face

private enum BrewRatingSadFaceStyle {
    case outline
    case filled
}

private struct BrewRatingSadFace: View {
    let style: BrewRatingSadFaceStyle
    let size: CGFloat
    
    private var eyeSize: CGFloat { size * 0.125 }
    private var eyeSpacing: CGFloat { size * 0.2 }
    private var eyeOffsetY: CGFloat { -size * 0.1 }
    private var mouthWidth: CGFloat { size * 0.4 }
    private var mouthHeight: CGFloat { size * 0.2 }
    private var mouthOffsetY: CGFloat { size * 0.2 }
    private var mouthLineWidth: CGFloat {
        style == .outline ? 2 : max(1.25, size * 0.125)
    }
    
    var body: some View {
        ZStack {
            if style == .outline {
                Circle()
                    .stroke(Color.secondary, lineWidth: 2)
                    .frame(width: size, height: size)
            } else {
                Circle()
                    .fill(Color(.label))
                    .frame(width: size, height: size)
            }
            
            HStack(spacing: eyeSpacing) {
                Circle()
                    .fill(eyeColor)
                    .frame(width: eyeSize, height: eyeSize)
                Circle()
                    .fill(eyeColor)
                    .frame(width: eyeSize, height: eyeSize)
            }
            .offset(y: eyeOffsetY)
            
            BrewRatingSadFaceMouth()
                .stroke(
                    mouthColor,
                    style: StrokeStyle(
                        lineWidth: mouthLineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(width: mouthWidth, height: mouthHeight)
                .scaleEffect(y: -1)
                .offset(y: mouthOffsetY)
        }
    }
    
    private var eyeColor: Color {
        style == .outline ? Color.primary.opacity(0.6) : Color(.systemBackground)
    }
    
    private var mouthColor: Color {
        style == .outline ? Color.primary.opacity(0.6) : Color(.systemBackground)
    }
}

private struct BrewRatingSadFaceMouth: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerY = rect.minY + rect.height * 0.1
        path.move(to: CGPoint(x: rect.minX, y: cornerY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: cornerY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

// MARK: - Neutral (filled, list)

struct BrewRatingNeutralFaceFilled: View {
    var size: CGFloat = 16
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.label))
                .frame(width: size, height: size)
            
            HStack(spacing: size * 0.1875) {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: size * 0.125, height: size * 0.125)
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: size * 0.125, height: size * 0.125)
            }
            .offset(y: -size * 0.125)
            
            Rectangle()
                .fill(Color(.systemBackground))
                .frame(width: size * 0.375, height: max(1, size * 0.09375))
                .offset(y: size * 0.1875)
        }
    }
}

private extension View {
    func brewRatingSymbolStyle() -> some View {
        font(.system(size: 16))
            .foregroundColor(.primary)
    }
}
