//
//  AudioService.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import AVFoundation
import Foundation

struct AudioSelectService {
    func makeAudioFile(from url: URL) async throws -> AudioFile {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let asset = AVURLAsset(
            url: url,
            options: [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        )

        let duration = try await asset.load(.duration)
        let fileSize = try FileManager.default
            .attributesOfItem(atPath: url.path)[.size] as? NSNumber

        let durationInSeconds = duration.seconds.isFinite ? duration.seconds : 0
        let bitrate = Self.estimatedBitrate(
            fileSizeInBytes: fileSize?.doubleValue,
            durationInSeconds: durationInSeconds
        )

        return AudioFile(
            name: url.deletingPathExtension().lastPathComponent,
            url: url,
            duration: durationInSeconds,
            bitrate: bitrate,
            format: url.pathExtension.uppercased(),
            bitDepth: try await bitDepth(for: asset)
        )
    }

    private func bitDepth(for asset: AVURLAsset) async throws -> Int {
        let tracks = try await asset.load(.tracks)
        guard let audioTrack = tracks.first(where: { $0.mediaType == .audio }) else {
            return 0
        }

        let formatDescriptions = try await audioTrack.load(.formatDescriptions)
        guard let audioDescription = formatDescriptions.first,
              let streamDescription = CMAudioFormatDescriptionGetStreamBasicDescription(audioDescription)
        else {
            return 0
        }

        return Int(streamDescription.pointee.mBitsPerChannel)
    }

    private static func estimatedBitrate(fileSizeInBytes: Double?, durationInSeconds: Double) -> Int {
        guard let fileSizeInBytes, durationInSeconds > 0 else {
            return 0
        }

        return Int((fileSizeInBytes * 8) / durationInSeconds)
    }
}
