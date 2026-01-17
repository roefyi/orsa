//
//  BrewShareCardView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import SwiftData
import UIKit
import Photos

struct BrewShareCardView: View {
    let brew: Brew
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var beans: [Bean]
    @Query private var equipment: [Equipment]
    @Query private var userProfiles: [UserProfile]
    
    @State private var shareImage: UIImage?
    
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
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top bar with dismiss button only
                    HStack {
                        Button {
                            HapticFeedback.light()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top + 8)
                    .padding(.bottom, 16)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Top header - orsa and date
                    HStack {
                        Text("orsa")
                            .font(.oscineBold(size: 24))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text(formattedDate)
                            .font(.oscineRegular(size: 14))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    // Parameters in grid
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(brewTimeDisplay)
                                .font(.oscineBold(size: 32))
                                .foregroundColor(.black)
                            Text("Time")
                                .font(.oscineRegular(size: 11))
                                .foregroundColor(.black)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(yieldDisplay)
                                .font(.oscineBold(size: 32))
                                .foregroundColor(.black)
                            Text("Yield")
                                .font(.oscineRegular(size: 11))
                                .foregroundColor(.black)
                        }
                        
                        if brew.dose > 0 {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(Int(brew.dose))g")
                                    .font(.oscineBold(size: 32))
                                    .foregroundColor(.black)
                                Text("Dose")
                                    .font(.oscineRegular(size: 11))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    HStack(alignment: .top, spacing: 16) {
                        if brew.temperature > 0 {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(Int(brew.temperature))°")
                                    .font(.oscineBold(size: 32))
                                    .foregroundColor(.black)
                                Text("Temp")
                                    .font(.oscineRegular(size: 11))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        if !brew.grindSetting.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(brew.grindSetting)
                                    .font(.oscineBold(size: 32))
                                    .foregroundColor(.black)
                                Text("Grind")
                                    .font(.oscineRegular(size: 11))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Bottom section - drink type
                    VStack(alignment: .leading, spacing: 4) {
                        Text(brew.drinkType)
                            .font(.oscineBold(size: 24))
                            .foregroundColor(.black)
                        
                        // Coffee name
                        if let bean = bean {
                            Text(bean.coffeeName)
                                .font(.oscineBold(size: 32))
                                .foregroundColor(.black)
                            
                            if !bean.roaster.isEmpty {
                                Text("by \(bean.roaster)")
                                    .font(.oscineRegular(size: 16))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .padding(24)
                .frame(width: 362, height: 433)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.0),
                                    Color(red: 1.0, green: 0.9, blue: 0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Share button below card
                VStack(spacing: 12) {
                    Button {
                        HapticFeedback.light()
                        generateShareImage { image in
                            // Directly present the share sheet with the generated image
                            if let image = image {
                                self.presentShareSheet(with: image)
                            }
                        }
                    } label: {
                        Text("share")
                            .font(.oscineHeadline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                }
            }
        }
    }
    
    private func presentShareSheet(with image: UIImage) {
        guard let pngData = image.pngData() else {
            print("Failed to convert image to PNG data")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [pngData], applicationActivities: nil)
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
        // Create a snapshot of the card view - exact dimensions 433h x 362w, card only
        // Must match the main view structure exactly - render full view with all padding
        let cardView = BrewShareCardContent(brew: brew, bean: bean, formattedDate: formattedDate, brewTimeDisplay: brewTimeDisplay, yieldDisplay: yieldDisplay)
            .frame(width: 362, height: 433)
            .environment(\.colorScheme, .light) // Force light mode for consistent rendering
        
        let hostingController = UIHostingController(rootView: cardView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 362, height: 433)
        hostingController.view.backgroundColor = .clear // Transparent background
        
        // Layout the view
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        // Render the full image first with all padding intact
        let size = CGSize(width: 362, height: 433)
        
        // Use async dispatch to ensure the view hierarchy is fully laid out
        DispatchQueue.main.async {
            // Add a small delay to ensure the hosting controller view is fully rendered
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let renderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat.default())
                let fullImage = renderer.image { context in
                    let rect = CGRect(origin: .zero, size: size)
                    // Draw the full view hierarchy with all padding
                    hostingController.view.drawHierarchy(in: rect, afterScreenUpdates: true)
                }
                
                // Apply border radius to final image (for PNG transparency)
                let finalRenderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat.default())
                let finalImage = finalRenderer.image { context in
                    let rect = CGRect(origin: .zero, size: size)
                    // Apply border radius clipping to final image only
                    let path = UIBezierPath(roundedRect: rect, cornerRadius: 24)
                    path.addClip()
                    fullImage.draw(in: rect)
                }
                
                self.shareImage = finalImage
                
                // Call completion handler with the generated image
                completion(finalImage)
            }
        }
    }
    
    private func shareCard(image: UIImage) {
        // Use PNG data for better quality and Instagram support
        guard let pngData = image.pngData() else {
            print("Failed to convert image to PNG data")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [pngData], applicationActivities: nil)
        // Don't exclude any activity types - let iOS show all available options including Messages and Instagram
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
    
    private func shareToInstagram(image: UIImage) {
        // Instagram Stories URL scheme
        guard let instagramURL = URL(string: "instagram-stories://share") else { return }
        
        if UIApplication.shared.canOpenURL(instagramURL) {
            // Save image to pasteboard for Instagram
            let pasteboard = UIPasteboard.general
            pasteboard.image = image
            
            // Open Instagram
            UIApplication.shared.open(instagramURL)
        } else {
            // Fallback to share sheet
            shareCard(image: image)
        }
    }
    
    private func saveToPhotos(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            // Convert to PNG to ensure correct format
            guard let pngData = image.pngData() else { return }
            guard let pngImage = UIImage(data: pngData) else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: pngImage)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        // Show success feedback
                        print("Image saved to photos as PNG")
                    } else if let error = error {
                        print("Error saving image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

// Card content for rendering
struct BrewShareCardContent: View {
    let brew: Brew
    let bean: Bean?
    let formattedDate: String
    let brewTimeDisplay: String
    let yieldDisplay: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top header - orsa and date
            HStack {
                Text("orsa")
                    .font(.oscineBold(size: 24))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.oscineRegular(size: 14))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // Parameters in grid
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(brewTimeDisplay)
                        .font(.oscineBold(size: 32))
                        .foregroundColor(.black)
                    Text("Time")
                        .font(.oscineRegular(size: 11))
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(yieldDisplay)
                        .font(.oscineBold(size: 32))
                        .foregroundColor(.black)
                    Text("Yield")
                        .font(.oscineRegular(size: 11))
                        .foregroundColor(.black)
                }
                
                if brew.dose > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(Int(brew.dose))g")
                            .font(.oscineBold(size: 32))
                            .foregroundColor(.black)
                        Text("Dose")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
            }
            
            HStack(alignment: .top, spacing: 16) {
                if brew.temperature > 0 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(Int(brew.temperature))°")
                            .font(.oscineBold(size: 32))
                            .foregroundColor(.black)
                        Text("Temp")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(.black)
                    }
                }
                
                if !brew.grindSetting.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(brew.grindSetting)
                            .font(.oscineBold(size: 32))
                            .foregroundColor(.black)
                        Text("Grind")
                            .font(.oscineRegular(size: 11))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
            }
            
            Spacer()
            
            // Bottom section - drink type
            VStack(alignment: .leading, spacing: 4) {
                Text(brew.drinkType)
                    .font(.oscineBold(size: 24))
                    .foregroundColor(.black)
                
                // Coffee name
                if let bean = bean {
                    Text(bean.coffeeName)
                        .font(.oscineBold(size: 32))
                        .foregroundColor(.black)
                    
                    if !bean.roaster.isEmpty {
                        Text("by \(bean.roaster)")
                            .font(.oscineRegular(size: 16))
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .padding(24)
        .frame(width: 362, height: 433)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.85, blue: 0.0),
                            Color(red: 1.0, green: 0.9, blue: 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // Don't exclude any activity types - let iOS show all available options including Messages and Instagram
        controller.excludedActivityTypes = []
        
        // Configure for iPad
        if let popover = controller.popoverPresentationController {
            // Use a default source view/rect for iPad
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
