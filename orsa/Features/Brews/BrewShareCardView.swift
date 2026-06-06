//
//  BrewShareCardView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData
import UIKit

enum BrewShareExport {
    static let canvasWidth: CGFloat = 360
    static let canvasHeight: CGFloat = 640
    static let renderScale: CGFloat = 3.0
    static let cardAspectRatio: CGFloat = 433.0 / 362.0
    static let cardHorizontalPadding: CGFloat = 24
}

enum BrewShareChrome {
    static let horizontalPadding: CGFloat = 20
    static let topPadding: CGFloat = 8
    static let topBarBottomPadding: CGFloat = 16
    static let bottomActionTopPadding: CGFloat = 24
    static let bottomActionBottomPadding: CGFloat = 12
}

struct BrewShareDismissButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

struct BrewShareTopBar: View {
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            BrewShareDismissButton(action: onDismiss)
            Spacer()
        }
        .padding(.horizontal, BrewShareChrome.horizontalPadding)
    }
}

struct BrewShareBottomActionButton: View {
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(BrewActionIcon.font)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, BrewShareChrome.horizontalPadding)
        .padding(.top, BrewShareChrome.bottomActionTopPadding)
        .padding(.bottom, BrewShareChrome.bottomActionBottomPadding)
    }
}

enum ShareDefaultCardStyle {
    case yellow
    case inverted
    
    var textColor: Color {
        switch self {
        case .yellow:
            return Color(red: 30/255.0, green: 30/255.0, blue: 30/255.0)
        case .inverted:
            return AppColors.buttonYellow
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .yellow:
            return AppGradients.shareYellow
        case .inverted:
            return AppGradients.shareBlack
        }
    }
    
    var toggled: ShareDefaultCardStyle {
        self == .yellow ? .inverted : .yellow
    }
}

enum ShareOverlayTextColor: String, CaseIterable, Identifiable {
    case black
    case white
    case yellow
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .black:
            return Color(red: 30/255.0, green: 30/255.0, blue: 30/255.0)
        case .white:
            return .white
        case .yellow:
            return AppColors.buttonYellow
        }
    }
    
    var swatchColor: Color { color }
    
    var next: ShareOverlayTextColor {
        let options = Self.allCases
        let index = options.firstIndex(of: self) ?? 0
        return options[(index + 1) % options.count]
    }
}

private extension View {
    @ViewBuilder
    func brewShareCardBackground(
        style: ShareDefaultCardStyle,
        cornerRadius: CGFloat,
        isVisible: Bool
    ) -> some View {
        if isVisible {
            background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(style.gradient)
            )
        } else {
            self
        }
    }
}

struct BrewShareLayoutPager<Card: View>: View {
    @Binding var selection: Int
    let pageCount: Int
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    @ViewBuilder let card: (Int) -> Card
    
    @State private var scrollPosition: Int?
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        HStack(spacing: 0) {
                            Spacer(minLength: 0)
                            card(index)
                                .frame(width: cardWidth, height: cardHeight)
                            Spacer(minLength: 0)
                        }
                        .containerRelativeFrame(.horizontal)
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollPosition)
            .scrollClipDisabled(false)
            .frame(height: cardHeight)
            .onAppear {
                scrollPosition = selection
            }
            .onChange(of: scrollPosition) { _, newValue in
                guard let newValue, newValue != selection else { return }
                selection = newValue
                HapticFeedback.light()
            }
            .onChange(of: selection) { _, newValue in
                guard scrollPosition != newValue else { return }
                withAnimation(.smooth(duration: 0.35)) {
                    scrollPosition = newValue
                }
            }
            
            HStack(spacing: 8) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Circle()
                        .fill(selection == index ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.smooth(duration: 0.2), value: selection)
                }
            }
        }
    }
}

struct BrewShareLayoutView: View {
    let layoutIndex: Int
    let brew: Brew
    let bean: Bean?
    let formattedDate: String
    let brewTimeDisplay: String
    let yieldDisplay: String
    var textColor: Color = .black
    var cardStyle: ShareDefaultCardStyle = .yellow
    var showsCardBackground: Bool = true
    
    var body: some View {
        switch layoutIndex {
        case 0:
            BrewShareCardLayout1(
                brew: brew,
                bean: bean,
                formattedDate: formattedDate,
                brewTimeDisplay: brewTimeDisplay,
                yieldDisplay: yieldDisplay,
                textColor: textColor,
                cardStyle: cardStyle,
                showsCardBackground: showsCardBackground
            )
        case 1:
            BrewShareCardLayout2(
                brew: brew,
                bean: bean,
                formattedDate: formattedDate,
                brewTimeDisplay: brewTimeDisplay,
                yieldDisplay: yieldDisplay,
                textColor: textColor,
                cardStyle: cardStyle,
                showsCardBackground: showsCardBackground
            )
        default:
            BrewShareCardLayout3(
                brew: brew,
                bean: bean,
                formattedDate: formattedDate,
                brewTimeDisplay: brewTimeDisplay,
                yieldDisplay: yieldDisplay,
                textColor: textColor,
                cardStyle: cardStyle,
                showsCardBackground: showsCardBackground
            )
        }
    }
}

struct BrewShareCardView: View {
    let brew: Brew
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var beans: [Bean]
    @Query private var equipment: [Equipment]
    @Query private var userProfiles: [UserProfile]
    
    @State private var currentCardIndex = 0
    @State private var showingMediaPicker = false
    @State private var customBackground: BrewShareCustomBackground?
    @State private var customLayoutIndex = 0
    @State private var customTextColorOption: ShareOverlayTextColor = .white
    @State private var defaultCardStyle: ShareDefaultCardStyle = .yellow
    @Environment(\.colorScheme) private var colorScheme
    
    private static let cardCount = 4
    private static let customLayoutCount = 3
    private var isCustomMediaCard: Bool { currentCardIndex == Self.cardCount - 1 }
    private var isComposingCustom: Bool { customBackground != nil }
    
    var bean: Bean? {
        guard let beanID = brew.beanID else { return nil }
        return beans.first { $0.id == beanID }
    }
    
    var userName: String {
        userProfiles.first?.name ?? ""
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: brew.timestamp)
    }
    
    var brewTimeDisplay: String {
        brew.brewTime
    }
    
    @AppStorage("yieldUnit") private var yieldUnit: String = "grams"
    
    var yieldDisplay: String {
        let unit = yieldUnit == "ml" ? "ml" : "g"
        return "\(Int(brew.yield))\(unit)"
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                BrewShareTopBar(onDismiss: { dismiss() })
                    .padding(.top, BrewShareChrome.topPadding)
                    .padding(.bottom, BrewShareChrome.topBarBottomPadding)
                
                GeometryReader { geometry in
                    let cardWidth = max(min(geometry.size.width - 48, 400), 100)
                    let cardHeight = cardWidth * BrewShareExport.cardAspectRatio
                    
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        
                        if isComposingCustom, let customBackground {
                            BrewShareLayoutPager(
                                selection: $customLayoutIndex,
                                pageCount: Self.customLayoutCount,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight
                            ) { index in
                                BrewShareMediaCardView(
                                    background: customBackground,
                                    layoutIndex: index,
                                    brew: brew,
                                    bean: bean,
                                    formattedDate: formattedDate,
                                    brewTimeDisplay: brewTimeDisplay,
                                    yieldDisplay: yieldDisplay,
                                    textColor: customTextColorOption.color
                                )
                                .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .onTapGesture {
                                    HapticFeedback.light()
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        customTextColorOption = customTextColorOption.next
                                    }
                                }
                            }
                        } else {
                            BrewShareLayoutPager(
                                selection: $currentCardIndex,
                                pageCount: Self.cardCount,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight
                            ) { index in
                                Group {
                                    switch index {
                                    case 0:
                                        BrewShareCardLayout1(
                                            brew: brew,
                                            bean: bean,
                                            formattedDate: formattedDate,
                                            brewTimeDisplay: brewTimeDisplay,
                                            yieldDisplay: yieldDisplay,
                                            textColor: defaultCardStyle.textColor,
                                            cardStyle: defaultCardStyle
                                        )
                                    case 1:
                                        BrewShareCardLayout2(
                                            brew: brew,
                                            bean: bean,
                                            formattedDate: formattedDate,
                                            brewTimeDisplay: brewTimeDisplay,
                                            yieldDisplay: yieldDisplay,
                                            textColor: defaultCardStyle.textColor,
                                            cardStyle: defaultCardStyle
                                        )
                                    case 2:
                                        BrewShareCardLayout3(
                                            brew: brew,
                                            bean: bean,
                                            formattedDate: formattedDate,
                                            brewTimeDisplay: brewTimeDisplay,
                                            yieldDisplay: yieldDisplay,
                                            textColor: defaultCardStyle.textColor,
                                            cardStyle: defaultCardStyle
                                        )
                                    default:
                                        BrewShareCardLayout4()
                                    }
                                }
                                .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .onTapGesture {
                                    guard index < Self.cardCount - 1 else { return }
                                    HapticFeedback.light()
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        defaultCardStyle = defaultCardStyle.toggled
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if isComposingCustom {
                    BrewShareBottomActionButton(systemImage: "checkmark") {
                        HapticFeedback.medium()
                        exportCustomComposition()
                    }
                } else if isCustomMediaCard {
                    BrewShareBottomActionButton(systemImage: BrewActionIcon.create) {
                        HapticFeedback.light()
                        showingMediaPicker = true
                    }
                } else {
                    BrewShareBottomActionButton(systemImage: BrewActionIcon.share) {
                        HapticFeedback.light()
                        generateShareImage { image in
                            if let image = image {
                                self.presentShareSheet(with: image)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingMediaPicker) {
            BrewShareMediaPicker { media in
                switch media {
                case .image(let image):
                    customBackground = .image(image)
                case .video(let url):
                    customBackground = .video(url)
                }
                customLayoutIndex = 0
                customTextColorOption = .white
            }
        }
    }
    
    private func exportCustomComposition() {
        guard let customBackground else { return }
        
        switch customBackground {
        case .image(let image):
            exportCustomImage(image)
        case .video(let videoURL):
            exportCustomVideo(from: videoURL)
        }
    }
    
    private func exportCustomImage(_ image: UIImage) {
        let cardWidth = BrewShareExport.canvasWidth - BrewShareExport.cardHorizontalPadding * 2
        let cardHeight = cardWidth * BrewShareExport.cardAspectRatio
        
        let finalView = ZStack {
            Color.appBackground
            
            BrewShareMediaCardView(
                background: .image(image),
                layoutIndex: customLayoutIndex,
                brew: brew,
                bean: bean,
                formattedDate: formattedDate,
                brewTimeDisplay: brewTimeDisplay,
                yieldDisplay: yieldDisplay,
                textColor: customTextColorOption.color
            )
            .frame(width: cardWidth, height: cardHeight)
        }
        .frame(width: BrewShareExport.canvasWidth, height: BrewShareExport.canvasHeight)
        .environment(\.colorScheme, colorScheme)
        
        let renderer = ImageRenderer(content: finalView)
        renderer.scale = BrewShareExport.renderScale
        
        DispatchQueue.main.async {
            if let image = renderer.uiImage {
                self.presentShareSheet(with: image)
            }
        }
    }
    
    private func exportCustomVideo(from videoURL: URL) {
        let cardWidth = BrewShareExport.canvasWidth - BrewShareExport.cardHorizontalPadding * 2
        let cardHeight = cardWidth * BrewShareExport.cardAspectRatio
        let renderSize = CGSize(
            width: cardWidth * BrewShareExport.renderScale,
            height: cardHeight * BrewShareExport.renderScale
        )
        
        guard let overlayImage = renderCustomOverlayImage(
            cardWidth: cardWidth,
            cardHeight: cardHeight
        ) else {
            print("Failed to render overlay for share video")
            return
        }
        
        Task {
            do {
                let exportedURL = try await BrewShareVideoExporter.exportVideo(
                    videoURL: videoURL,
                    overlayImage: overlayImage,
                    renderSize: renderSize
                )
                await MainActor.run {
                    self.presentShareSheet(items: [exportedURL])
                }
            } catch {
                print("Error exporting share video: \(error)")
            }
        }
    }
    
    private func renderCustomOverlayImage(cardWidth: CGFloat, cardHeight: CGFloat) -> UIImage? {
        let designWidth: CGFloat = 362
        let designHeight: CGFloat = 433
        let scale = min(cardWidth / designWidth, cardHeight / designHeight)
        
        let overlayView = ZStack {
            Color.clear
            BrewShareLayoutView(
                layoutIndex: customLayoutIndex,
                brew: brew,
                bean: bean,
                formattedDate: formattedDate,
                brewTimeDisplay: brewTimeDisplay,
                yieldDisplay: yieldDisplay,
                textColor: customTextColorOption.color,
                showsCardBackground: false
            )
            .frame(width: designWidth, height: designHeight)
            .scaleEffect(scale)
        }
        .frame(width: cardWidth, height: cardHeight)
        .environment(\.colorScheme, colorScheme)
        
        let renderer = ImageRenderer(content: overlayView)
        renderer.scale = BrewShareExport.renderScale
        return renderer.uiImage
    }
    
    private func presentShareSheet(with image: UIImage) {
        guard let pngData = image.pngData() else {
            print("Failed to convert image to PNG data")
            return
        }
        presentShareSheet(items: [pngData])
    }
    
    private func presentShareSheet(items: [Any]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = []
        
        // Find the topmost view controller to present from
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("Failed to find root view controller")
            return
        }
        
        // Find the topmost presented view controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        // For iPad, set popover presentation
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topController.view
            popover.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        topController.present(activityVC, animated: true)
    }
    
    private func generateShareImage(completion: @escaping (UIImage?) -> Void) {
        let cardWidth = BrewShareExport.canvasWidth - BrewShareExport.cardHorizontalPadding * 2
        let cardHeight = cardWidth * BrewShareExport.cardAspectRatio
        
        let cardView = BrewShareLayoutView(
            layoutIndex: currentCardIndex,
            brew: brew,
            bean: bean,
            formattedDate: formattedDate,
            brewTimeDisplay: brewTimeDisplay,
            yieldDisplay: yieldDisplay,
            textColor: defaultCardStyle.textColor,
            cardStyle: defaultCardStyle
        )
        .frame(width: cardWidth, height: cardHeight)
        
        let finalView = ZStack {
            Color.appBackground
            cardView
        }
        .frame(width: BrewShareExport.canvasWidth, height: BrewShareExport.canvasHeight)
        .environment(\.colorScheme, colorScheme)
        
        let renderer = ImageRenderer(content: finalView)
        renderer.scale = BrewShareExport.renderScale
        
        DispatchQueue.main.async {
            completion(renderer.uiImage)
        }
    }
}

// Card Layout 4 - Custom image/video
struct BrewShareCardLayout4: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.cardBackground)
            
            VStack(spacing: 16) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(.primary)
                
                Text("use your own image/video")
                    .font(.oscineRegular(size: 20))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        Color.primary.opacity(0.35),
                        style: StrokeStyle(lineWidth: 2, dash: [10, 8])
                    )
                    .padding(20)
            }
        }
    }
}

// Card Layout 1 - Original (for display with rounded corners)
struct BrewShareCardLayout1: View {
    let brew: Brew
    let bean: Bean?
    let formattedDate: String
    let brewTimeDisplay: String
    let yieldDisplay: String
    var textColor: Color = .black
    var cardStyle: ShareDefaultCardStyle = .yellow
    var showsCardBackground: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top header - orsa and date
            HStack {
                Text("orsa")
                    .font(.oscineBold(size: 24))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.oscineRegular(size: 14))
                    .foregroundColor(textColor)
            }
            
            Spacer()
            
            // Parameters in grid
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(brewTimeDisplay)
                        .font(.oscineBold(size: 32))
                        .foregroundColor(textColor)
                    Text("Time")
                        .font(.oscineRegular(size: 11))
                        .foregroundColor(textColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(yieldDisplay)
                        .font(.oscineBold(size: 32))
                        .foregroundColor(textColor)
                    Text("Yield")
                        .font(.oscineRegular(size: 11))
                        .foregroundColor(textColor)
                }
                
                if brew.dose > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(Int(brew.dose))g")
                            .font(.oscineBold(size: 32))
                            .foregroundColor(textColor)
                        Text("Dose")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(textColor)
                    }
                }
                
                Spacer()
            }
            
            HStack(alignment: .top, spacing: 16) {
                if brew.temperature > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(Int(brew.temperature))°")
                            .font(.oscineBold(size: 32))
                            .foregroundColor(textColor)
                        Text("Temp")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(textColor)
                    }
                }
                
                if !brew.grindSetting.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(brew.grindSetting)
                            .font(.oscineBold(size: 32))
                            .foregroundColor(textColor)
                        Text("Grind")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(textColor)
                    }
                }
                
                Spacer()
            }
            
            Spacer()
                .frame(height: 12)
            
            // Bottom section - drink type
            VStack(alignment: .leading, spacing: 4) {
                Text(brew.drinkType)
                    .font(.oscineBold(size: 24))
                    .foregroundColor(textColor)
                
                // Coffee name
                if let bean = bean {
                    Text(bean.coffeeName)
                        .font(.oscineBold(size: 32))
                        .foregroundColor(textColor)
                    
                    if !bean.roaster.isEmpty {
                        Text("by \(bean.roaster)")
                            .font(.oscineRegular(size: 16))
                            .foregroundColor(textColor)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
        .brewShareCardBackground(style: cardStyle, cornerRadius: 24, isVisible: showsCardBackground)
    }
}

// Card Layout 2 - Centered (for display with rounded corners)
struct BrewShareCardLayout2: View {
    let brew: Brew
    let bean: Bean?
    let formattedDate: String
    let brewTimeDisplay: String
    let yieldDisplay: String
    var textColor: Color = .black
    var cardStyle: ShareDefaultCardStyle = .yellow
    var showsCardBackground: Bool = true
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Top header - date
            HStack {
                Spacer()
                Text(formattedDate)
                    .font(.oscineRegular(size: 14))
                    .foregroundColor(textColor)
                Spacer()
            }
            
            Spacer()
            
            // Centered drink type
            Text(brew.drinkType)
                .font(.oscineBold(size: 24))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
            
            Spacer()
                .frame(height: 24)
            
            // Parameters in centered layout
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .center, spacing: 2) {
                    Text(brewTimeDisplay)
                        .font(.oscineBold(size: 32))
                        .foregroundColor(textColor)
                    Text("Time")
                        .font(.oscineRegular(size: 11))
                        .foregroundColor(textColor)
                }
                
                VStack(alignment: .center, spacing: 2) {
                    Text(yieldDisplay)
                        .font(.oscineBold(size: 32))
                        .foregroundColor(textColor)
                    Text("Yield")
                        .font(.oscineRegular(size: 11))
                        .foregroundColor(textColor)
                }
                
                if brew.dose > 0 {
                    VStack(alignment: .center, spacing: 2) {
                        Text("\(Int(brew.dose))g")
                            .font(.oscineBold(size: 32))
                            .foregroundColor(textColor)
                        Text("Dose")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(textColor)
                    }
                }
            }
            
            Spacer()
                .frame(height: 12)
            
            HStack(alignment: .top, spacing: 16) {
                if brew.temperature > 0 {
                    VStack(alignment: .center, spacing: 2) {
                        Text("\(Int(brew.temperature))°")
                            .font(.oscineBold(size: 32))
                            .foregroundColor(textColor)
                        Text("Temp")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(textColor)
                    }
                }
                
                if !brew.grindSetting.isEmpty {
                    VStack(alignment: .center, spacing: 2) {
                        Text(brew.grindSetting)
                            .font(.oscineBold(size: 32))
                            .foregroundColor(textColor)
                        Text("Grind")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(textColor)
                    }
                }
            }
            
            Spacer()
            
            // Bottom - orsa branding
            Text("orsa")
                .font(.oscineBold(size: 24))
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .brewShareCardBackground(style: cardStyle, cornerRadius: 24, isVisible: showsCardBackground)
    }
}

// Card Layout 3 - Bottom Aligned (for display with rounded corners)
struct BrewShareCardLayout3: View {
    let brew: Brew
    let bean: Bean?
    let formattedDate: String
    let brewTimeDisplay: String
    let yieldDisplay: String
    var textColor: Color = .black
    var cardStyle: ShareDefaultCardStyle = .yellow
    var showsCardBackground: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top header - orsa and date
            HStack {
                Text("orsa")
                    .font(.oscineBold(size: 24))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.oscineRegular(size: 14))
                    .foregroundColor(textColor)
            }
            
            Spacer()
            
            // Bottom section - drink type and bean info
            VStack(alignment: .leading, spacing: 0) {
                // Drink type and coffee name in one line with baseline alignment
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(brew.drinkType)
                        .font(.oscineBold(size: 24))
                        .foregroundColor(textColor)
                    
                    if let bean = bean {
                        Text(bean.coffeeName)
                            .font(.oscineRegular(size: 16))
                            .foregroundColor(textColor)
                    }
                }
                
                Spacer()
                    .frame(height: 12)
                
                // Parameters in horizontal row with even spacing - all same font size
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(brewTimeDisplay)
                            .font(.oscineBold(size: 24))
                            .foregroundColor(textColor)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Text("Time")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(textColor)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(yieldDisplay)
                            .font(.oscineBold(size: 24))
                            .foregroundColor(textColor)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Text("Yield")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(textColor)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    if brew.dose > 0 {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(Int(brew.dose))g")
                                .font(.oscineBold(size: 24))
                                .foregroundColor(textColor)
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                            Text("Dose")
                                .font(.oscineRegular(size: 11))
                                .foregroundColor(textColor)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if !brew.grindSetting.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(brew.grindSetting)
                                .font(.oscineBold(size: 24))
                                .foregroundColor(textColor)
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                            Text("Grind")
                                .font(.oscineRegular(size: 11))
                                .foregroundColor(textColor)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if brew.temperature > 0 {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(Int(brew.temperature))°")
                                .font(.oscineBold(size: 24))
                                .foregroundColor(textColor)
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                            Text("Temp")
                                .font(.oscineRegular(size: 11))
                                .foregroundColor(textColor)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
        .brewShareCardBackground(style: cardStyle, cornerRadius: 24, isVisible: showsCardBackground)
    }
}

#Preview {
    let brew = Brew(
        drinkType: "Cortado",
        dose: 18.0,
        grindSetting: "3.5",
        temperature: 200.0,
        brewTime: "28s",
        yield: 36.0
    )
    return BrewShareCardView(brew: brew)
        .modelContainer(for: [Brew.self, Bean.self, Equipment.self, UserProfile.self])
}
