//
//  AudioService.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import AVFoundation
import Foundation

struct AudioSelectService {
    private let metadataService: SPFKMetadataService

    init(metadataService: SPFKMetadataService = SPFKMetadataService()) {
        self.metadataService = metadataService
    }

    func makeAudioFile(from url: URL) async throws -> AudioFile {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        return try await loadAudioFile(from: url)
    }

    func saveMetadata(
        _ metadata: EditableAudioMetadata,
        from sourceURL: URL,
        destination: MetadataSaveDestination
    ) async throws -> AudioFile {
        let didStartAccessing = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let writableURL = try writableAudioURL(from: sourceURL, destination: destination)
        try metadataService.saveMetadata(metadata, to: writableURL)
        return try await loadAudioFile(from: writableURL)
    }

    private func writableAudioURL(
        from sourceURL: URL,
        destination: MetadataSaveDestination
    ) throws -> URL {
        switch destination {
        case .original:
            return sourceURL
        case .copy(let copyURL):
            let fileManager = FileManager.default

            if fileManager.fileExists(atPath: copyURL.path) {
                try fileManager.removeItem(at: copyURL)
            }

            try fileManager.copyItem(at: sourceURL, to: copyURL)
            return copyURL
        }
    }

    private func loadAudioFile(from url: URL) async throws -> AudioFile {
        async let avInfo = technicalInfoWithAVFoundation(from: url)
        let spfkInfo = try? metadataService.readTechnicalInfo(from: url)
        let metadata = try? metadataService.readMetadata(from: url)
        let technicalInfo = try await spfkInfo.mergingMissingValues(with: avInfo)

        return AudioFile(
            name: metadata?.title ?? url.deletingPathExtension().lastPathComponent,
            url: url,
            duration: technicalInfo.duration,
            bitrate: technicalInfo.bitrate,
            sampleRate: technicalInfo.sampleRate,
            channelCount: technicalInfo.channelCount,
            format: url.pathExtension.uppercased(),
            bitDepth: technicalInfo.bitDepth,
            metadata: metadata?.hasVisibleValues == true ? metadata : nil
        )
    }

    private func technicalInfoWithAVFoundation(from url: URL) async throws -> AudioTechnicalInfo {
        let asset = AVURLAsset(
            url: url,
            options: [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        )

        let duration = try await asset.load(.duration)
        let tracks = try await asset.load(.tracks)
        let audioTrack = tracks.first { $0.mediaType == .audio }
        let formatDescription = try await audioTrack?.load(.formatDescriptions).first
        let streamDescription = formatDescription.flatMap(CMAudioFormatDescriptionGetStreamBasicDescription)
        let durationInSeconds = duration.seconds.isFinite ? duration.seconds : 0
        let fileSize = try FileManager.default
            .attributesOfItem(atPath: url.path)[.size] as? NSNumber

        return AudioTechnicalInfo(
            duration: durationInSeconds,
            bitrate: Self.estimatedBitrate(
                fileSizeInBytes: fileSize?.doubleValue,
                durationInSeconds: durationInSeconds
            ),
            sampleRate: streamDescription?.pointee.mSampleRate ?? 0,
            channelCount: Int(streamDescription?.pointee.mChannelsPerFrame ?? 0),
            bitDepth: Int(streamDescription?.pointee.mBitsPerChannel ?? 0)
        )
    }

    private static func estimatedBitrate(fileSizeInBytes: Double?, durationInSeconds: Double) -> Int {
        guard let fileSizeInBytes, durationInSeconds > 0 else {
            return 0
        }

        return Int((fileSizeInBytes * 8) / durationInSeconds)
    }
}

private extension Optional where Wrapped == AudioTechnicalInfo {
    func mergingMissingValues(with fallback: AudioTechnicalInfo) -> AudioTechnicalInfo {
        guard let info = self else {
            return fallback
        }

        return AudioTechnicalInfo(
            duration: info.duration > 0 ? info.duration : fallback.duration,
            bitrate: info.bitrate > 0 ? info.bitrate : fallback.bitrate,
            sampleRate: info.sampleRate > 0 ? info.sampleRate : fallback.sampleRate,
            channelCount: info.channelCount > 0 ? info.channelCount : fallback.channelCount,
            bitDepth: info.bitDepth > 0 ? info.bitDepth : fallback.bitDepth
        )
    }
}
