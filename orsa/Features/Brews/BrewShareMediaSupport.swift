//
//  BrewShareMediaSupport.swift
//  orsa
//

import AVFoundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

enum BrewShareCustomBackground {
    case image(UIImage)
    case video(URL)
}

enum BrewSharePickedMedia {
    case image(UIImage)
    case video(URL)
}

struct BrewShareMediaCardView: View {
    let background: BrewShareCustomBackground
    let layoutIndex: Int
    let brew: Brew
    let bean: Bean?
    let formattedDate: String
    let brewTimeDisplay: String
    let yieldDisplay: String
    var textColor: Color = .white
    
    private static let designWidth: CGFloat = 362
    private static let designHeight: CGFloat = 433
    private static let cornerRadius: CGFloat = 24
    
    var body: some View {
        GeometryReader { proxy in
            let scale = min(
                proxy.size.width / Self.designWidth,
                proxy.size.height / Self.designHeight
            )
            
            ZStack {
                switch background {
                case .image(let image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                case .video(let url):
                    BrewShareLoopingVideoView(url: url)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
                
                BrewShareLayoutView(
                    layoutIndex: layoutIndex,
                    brew: brew,
                    bean: bean,
                    formattedDate: formattedDate,
                    brewTimeDisplay: brewTimeDisplay,
                    yieldDisplay: yieldDisplay,
                    textColor: textColor,
                    showsCardBackground: false
                )
                .frame(width: Self.designWidth, height: Self.designHeight)
                .scaleEffect(scale)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        }
    }
}

struct BrewShareLoopingVideoView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> BrewShareLoopingPlayerView {
        let view = BrewShareLoopingPlayerView()
        view.configure(url: url)
        return view
    }
    
    func updateUIView(_ uiView: BrewShareLoopingPlayerView, context: Context) {
        uiView.configure(url: url)
    }
    
    static func dismantleUIView(_ uiView: BrewShareLoopingPlayerView, coordinator: ()) {
        uiView.reset()
    }
}

final class BrewShareLoopingPlayerView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var endObserver: NSObjectProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(url: URL) {
        reset()
        
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        item.preferredForwardBufferDuration = 1
        
        let player = AVPlayer(playerItem: item)
        player.isMuted = true
        player.automaticallyWaitsToMinimizeStalling = false
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        player.playImmediately(atRate: 1.0)
        self.player = player
        self.playerLayer = playerLayer
        setNeedsLayout()
    }
    
    func reset() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    deinit {
        reset()
    }
}

struct BrewShareMediaPicker: UIViewControllerRepresentable {
    let onMedia: (BrewSharePickedMedia) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .any(of: [.images, .videos])
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: BrewShareMediaPicker
        
        init(_ parent: BrewShareMediaPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let itemProvider = results.first?.itemProvider else { return }
            
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                    guard let url else { return }
                    
                    let destinationURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension(url.pathExtension.isEmpty ? "mov" : url.pathExtension)
                    
                    do {
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            try FileManager.default.removeItem(at: destinationURL)
                        }
                        try FileManager.default.copyItem(at: url, to: destinationURL)
                        
                        DispatchQueue.main.async {
                            self.parent.onMedia(.video(destinationURL))
                        }
                    } catch {
                        print("Error copying picked video: \(error)")
                    }
                }
                return
            }
            
            guard itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
            
            itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                guard let image = object as? UIImage else { return }
                DispatchQueue.main.async {
                    self.parent.onMedia(.image(image))
                }
            }
        }
    }
}
