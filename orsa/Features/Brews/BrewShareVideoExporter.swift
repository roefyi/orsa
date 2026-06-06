//
//  BrewShareVideoExporter.swift
//  orsa
//

import AVFoundation
import UIKit

enum BrewShareVideoExporter {
    enum ExportError: Error {
        case missingVideoTrack
        case compositionFailed
        case exportSessionFailed
        case exportFailed
    }
    
    static func exportVideo(
        videoURL: URL,
        overlayImage: UIImage,
        canvasSize: CGSize,
        cardFrame: CGRect,
        backgroundColor: UIColor,
        cornerRadius: CGFloat
    ) async throws -> URL {
        let asset = AVURLAsset(url: videoURL)
        let videoTracks = try await asset.loadTracks(withMediaType: .video)
        guard let sourceVideoTrack = videoTracks.first else {
            throw ExportError.missingVideoTrack
        }
        
        let duration = try await asset.load(.duration)
        let naturalSize = try await sourceVideoTrack.load(.naturalSize)
        let preferredTransform = try await sourceVideoTrack.load(.preferredTransform)
        
        let composition = AVMutableComposition()
        guard let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw ExportError.compositionFailed
        }
        
        try compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: duration),
            of: sourceVideoTrack,
            at: .zero
        )
        
        if let sourceAudioTrack = try await asset.loadTracks(withMediaType: .audio).first,
           let compositionAudioTrack = composition.addMutableTrack(
               withMediaType: .audio,
               preferredTrackID: kCMPersistentTrackID_Invalid
           ) {
            try? compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: duration),
                of: sourceAudioTrack,
                at: .zero
            )
        }
        
        let orientedSize = naturalSize.applying(preferredTransform)
        let sourceSize = CGSize(width: abs(orientedSize.width), height: abs(orientedSize.height))
        var transform = aspectFillTransform(
            sourceSize: sourceSize,
            targetSize: cardFrame.size,
            preferredTransform: preferredTransform
        )
        transform = transform.concatenating(
            CGAffineTransform(translationX: cardFrame.origin.x, y: cardFrame.origin.y)
        )
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(transform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = canvasSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.instructions = [instruction]
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: canvasSize)
        
        let backgroundLayer = CALayer()
        backgroundLayer.frame = parentLayer.bounds
        backgroundLayer.backgroundColor = backgroundColor.cgColor
        parentLayer.addSublayer(backgroundLayer)
        
        let videoLayer = CALayer()
        videoLayer.frame = parentLayer.bounds
        
        let videoMask = CAShapeLayer()
        videoMask.path = CGPath(
            roundedRect: cardFrame,
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        )
        videoLayer.mask = videoMask
        parentLayer.addSublayer(videoLayer)
        
        let overlayLayer = CALayer()
        overlayLayer.frame = cardFrame
        overlayLayer.cornerRadius = cornerRadius
        overlayLayer.masksToBounds = true
        overlayLayer.contents = overlayImage.cgImage
        overlayLayer.contentsScale = overlayImage.scale
        overlayLayer.contentsGravity = .resize
        parentLayer.addSublayer(overlayLayer)
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: parentLayer
        )
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw ExportError.exportSessionFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition
        
        await exportSession.export()
        
        guard exportSession.status == .completed else {
            throw exportSession.error ?? ExportError.exportFailed
        }
        
        return outputURL
    }
    
    private static func aspectFillTransform(
        sourceSize: CGSize,
        targetSize: CGSize,
        preferredTransform: CGAffineTransform
    ) -> CGAffineTransform {
        let widthScale = targetSize.width / sourceSize.width
        let heightScale = targetSize.height / sourceSize.height
        let scale = max(widthScale, heightScale)
        
        let scaledWidth = sourceSize.width * scale
        let scaledHeight = sourceSize.height * scale
        let xOffset = (targetSize.width - scaledWidth) / 2
        let yOffset = (targetSize.height - scaledHeight) / 2
        
        var transform = preferredTransform
        transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
        transform = transform.concatenating(CGAffineTransform(translationX: xOffset, y: yOffset))
        return transform
    }
}
