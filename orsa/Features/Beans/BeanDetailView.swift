//
//  BeanDetailView.swift
//  orsa
//
//  Created by Rome on 1/9/26.
//

import SwiftUI
import UIKit

struct BeanDetailView: View {
    let bean: Bean
    
    @Environment(\.modelContext) private var modelContext
    @State private var showingImagePicker = false
    @State private var showingImageSourcePicker = false
    @State private var selectedImage: UIImage?
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingEditBean = false
    @State private var showingDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var roastDateString: String {
        if let roastDate = bean.roastDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter.string(from: roastDate)
        }
        return ""
    }
    
    var tastingNoteTags: [String] {
        guard let notes = bean.tastingNotes, !notes.isEmpty else { return [] }
        // Split by comma or newline, trim whitespace, filter empty
        return notes.components(separatedBy: CharacterSet(charactersIn: ",\n"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card with Photo
                VStack(alignment: .leading, spacing: 0) {
                    // Photo - no padding, tappable
                    Button {
                        showingImageSourcePicker = true
                    } label: {
                        ZStack {
                            if let photoData = bean.photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Rectangle()
                                    .fill(Color.appBackground)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.secondaryText)
                                            Text("Tap to add photo")
                                                .font(.oscineCaption)
                                                .foregroundColor(.secondaryText)
                                        }
                                    )
                            }
                        }
                        .frame(height: 200)
                        .clipped()
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Bean Name and Roaster
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bean.coffeeName)
                            .font(.oscineLargeTitle)
                            .foregroundColor(.cardText)
                        
                        Text(bean.roaster)
                            .font(.oscineSubheadline)
                            .foregroundColor(.cardText.opacity(0.7))
                    }
                    .padding(16)
                }
                .background(Color.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Roast Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Roast")
                            .font(.oscineHeadline)
                            .foregroundColor(.cardText)
                        Spacer()
                        Image(systemName: "flame.fill")
                            .foregroundColor(.cardText)
                            .font(.system(size: 16))
                    }
                    
                    if bean.roastDate != nil {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.cardText)
                                    .font(.system(size: 14))
                                Text("Roast Date")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.cardText)
                            }
                            Text(roastDateString)
                                .font(.oscineBody)
                                .foregroundColor(.cardText.opacity(0.7))
                        }
                    }
                    
                    if let roastLevel = bean.roastLevel, !roastLevel.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.cardText)
                                    .font(.system(size: 14))
                                Text("Roast Level")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.cardText)
                            }
                            Text(roastLevel.capitalized)
                                .font(.oscineBody)
                                .foregroundColor(.cardText.opacity(0.7))
                        }
                    }
                    
                    if !tastingNoteTags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tasting Notes")
                                .font(.oscineSubheadline)
                                .foregroundColor(.cardText)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(tastingNoteTags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.oscineCaption)
                                        .foregroundColor(.cardText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.cardText.opacity(0.2))
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Origin Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Origin")
                            .font(.oscineHeadline)
                            .foregroundColor(.cardText)
                        Spacer()
                        Image(systemName: "globe")
                            .foregroundColor(.cardText)
                            .font(.system(size: 16))
                    }
                    
                    if let country = bean.origin, !country.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "globe")
                                    .foregroundColor(.cardText)
                                    .font(.system(size: 14))
                                Text("Country")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.cardText)
                            }
                            Text(country)
                                .font(.oscineBody)
                                .foregroundColor(.cardText.opacity(0.7))
                        }
                    }
                    
                    if let process = bean.process, !process.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.cardText)
                                    .font(.system(size: 14))
                                Text("Processing Method")
                                    .font(.oscineSubheadline)
                                    .foregroundColor(.cardText)
                            }
                            Text(process.capitalized)
                                .font(.oscineBody)
                                .foregroundColor(.cardText.opacity(0.7))
                        }
                    }
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Settings Card (only show if temperature or grind setting exists)
                if let temp = bean.temperature, !temp.isEmpty || (bean.grindSetting != nil && !bean.grindSetting!.isEmpty) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Settings")
                                .font(.oscineHeadline)
                                .foregroundColor(.cardText)
                            Spacer()
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.cardText)
                                .font(.system(size: 16))
                        }
                        
                        if let temp = bean.temperature, !temp.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "thermometer")
                                        .foregroundColor(.cardText)
                                        .font(.system(size: 14))
                                    Text("Temperature")
                                        .font(.oscineSubheadline)
                                        .foregroundColor(.cardText)
                                }
                                Text(temp)
                                    .font(.oscineBody)
                                    .foregroundColor(.cardText.opacity(0.7))
                            }
                        }
                        
                        if let grind = bean.grindSetting, !grind.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(.cardText)
                                        .font(.system(size: 14))
                                    Text("Grind Setting")
                                        .font(.oscineSubheadline)
                                        .foregroundColor(.cardText)
                                }
                                Text(grind)
                                    .font(.oscineBody)
                                    .foregroundColor(.cardText.opacity(0.7))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                
                // Delete Button
                VStack(spacing: 12) {
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Text("delete")
                            .font(.oscineHeadline)
                            .foregroundColor(.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            .padding(.bottom, 100)
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditBean = true
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showingEditBean) {
            EditBeanView(existingBean: bean)
        }
        .confirmationDialog("Delete Bean", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteBean()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \(bean.coffeeName)? This action cannot be undone.")
        }
        .confirmationDialog("Select Image Source", isPresented: $showingImageSourcePicker) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Camera") {
                    imageSourceType = .camera
                    showingImagePicker = true
                }
            }
            Button("Photo Library") {
                imageSourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: imageSourceType, selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            if let image = newValue {
                saveImageToBean(image)
            }
        }
    }
    
    private func saveImageToBean(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            bean.photoData = imageData
            do {
                try modelContext.save()
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
    
    private func deleteBean() {
        modelContext.delete(bean)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting bean: \(error)")
        }
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// FlowLayout helper for wrapping tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? 0,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    let bean = Bean(
        coffeeName: "Ethiopian Yirgacheffe",
        roaster: "Blue Bottle",
        roastDate: Date(),
        process: "Washed",
        origin: "Ethiopia"
    )
    NavigationStack {
        BeanDetailView(bean: bean)
    }
}
