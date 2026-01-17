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
                
                BrewShareCardContent(brew: brew, bean: bean, formattedDate: formattedDate, brewTimeDisplay: brewTimeDisplay, yieldDisplay: yieldDisplay)
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
        // Create a snapshot of the card view - exact dimensions 440h x 360w
        let cardView = BrewShareCardContent(brew: brew, bean: bean, formattedDate: formattedDate, brewTimeDisplay: brewTimeDisplay, yieldDisplay: yieldDisplay)
            .frame(width: 360, height: 440)
            .environment(\.colorScheme, .light) // Force light mode for consistent rendering
        
        let hostingController = UIHostingController(rootView: cardView)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 360, height: 440)
        hostingController.view.backgroundColor = .clear // Transparent background
        
        // Layout the view
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        // Render the full image first with all padding intact
        let size = CGSize(width: 360, height: 440)
        
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
        ZStack {
            // Yellow background with rounded corners
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.95, green: 0.82, blue: 0.22))
                .frame(width: 360, height: 440)
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("orsa")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)
                
                Spacer()
                    .frame(height: 80)
                
                // Brew parameters - first row
                HStack(spacing: 32) {
                    BrewParameter(value: brewTimeDisplay, label: "Time")
                    BrewParameter(value: yieldDisplay, label: "Yield")
                    if brew.dose > 0 {
                        BrewParameter(value: "\(Int(brew.dose))g", label: "Dose")
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer()
                    .frame(height: 24)
                
                // Temperature and Grind - second row
                HStack(spacing: 32) {
                    if brew.temperature > 0 {
                        BrewParameter(value: "\(Int(brew.temperature))°", label: "Temp")
                    }
                    if !brew.grindSetting.isEmpty {
                        BrewParameter(value: brew.grindSetting, label: "Grind")
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer()
                    .frame(height: 32)
                
                // Coffee name
                VStack(alignment: .leading, spacing: 4) {
                    Text(brew.drinkType)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.black)
                    
                    if let bean = bean {
                        Text(bean.coffeeName)
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.black)
                        
                        if !bean.roaster.isEmpty {
                            Text("by \(bean.roaster)")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 32)
            }
        }
        .frame(width: 360, height: 440)
    }
}

struct BrewParameter: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
        }
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
