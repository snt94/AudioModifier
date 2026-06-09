//
//  SPFKMetadataService.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation

#if canImport(AppKit)
import AppKit
#endif

#if canImport(SPFKMetadata)
import SPFKMetadata
#endif

#if canImport(SPFKMetadataC)
import SPFKMetadataC
#endif

struct SPFKMetadataService {
    func readMetadata(from url: URL) throws -> AudioMetadata? {
        #if canImport(SPFKMetadata)
        let properties = try TagProperties(url: url)

        return AudioMetadata(
            title: properties[.title],
            artist: properties[.artist],
            album: properties[.album],
            albumArtist: properties[.albumArtist],
            genre: properties[.genre],
            date: properties[.date],
            trackNumber: properties[.trackNumber],
            composer: properties[.composer],
            comment: properties[.comment],
            coverImageData: coverImageData(from: url),
            tags: visibleTags(from: properties)
        )
        #else
        return nil
        #endif
    }

    func readTechnicalInfo(from url: URL) throws -> AudioTechnicalInfo? {
        #if canImport(SPFKMetadata)
        guard let properties = try TagProperties(url: url).audioProperties else {
            return nil
        }

        return AudioTechnicalInfo(
            duration: properties.duration,
            bitrate: Int(properties.bitRate ?? 0) * 1_000,
            sampleRate: properties.sampleRate,
            channelCount: Int(properties.channelCount),
            bitDepth: properties.bitsPerChannel ?? 0
        )
        #else
        return nil
        #endif
    }

    func saveMetadata(_ metadata: EditableAudioMetadata, to url: URL) throws {
        #if canImport(SPFKMetadata)
        var properties = try TagProperties(url: url)
        properties[.title] = metadata.title.nilIfBlank
        properties[.artist] = metadata.artist.nilIfBlank
        properties[.album] = metadata.album.nilIfBlank
        properties[.albumArtist] = metadata.albumArtist.nilIfBlank
        properties[.genre] = metadata.genre.nilIfBlank
        properties[.date] = metadata.date.nilIfBlank
        properties[.trackNumber] = metadata.trackNumber.nilIfBlank
        properties[.composer] = metadata.composer.nilIfBlank
        properties[.comment] = metadata.comment.nilIfBlank
        try properties.save(to: url)

        if metadata.didChangeCoverImage, let coverImageData = metadata.coverImageData {
            try saveCoverImage(from: coverImageData, to: url)
        }
        #else
        throw NSError(
            domain: "AudioModifier.SPFKMetadataService",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Vincule o produto SPFKMetadata ao target do app para salvar metadados."]
        )
        #endif
    }

    #if canImport(SPFKMetadata)
    private func visibleTags(from properties: TagProperties) -> [AudioMetadataItem] {
        let primaryKeys: Set<TagKey> = [
            .title,
            .artist,
            .album,
            .albumArtist,
            .genre,
            .date,
            .trackNumber,
            .composer,
            .comment
        ]

        let standardTags = properties.tags
            .filter { !primaryKeys.contains($0.key) }
            .map { AudioMetadataItem(name: $0.key.displayName, value: $0.value) }

        let customTags = properties.customTags
            .map { AudioMetadataItem(name: $0.key, value: $0.value) }

        return (standardTags + customTags)
            .filter { !$0.value.isEmpty }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private func saveCoverImage(from imageData: Data, to audioURL: URL) throws {
        let jpegData = try CoverImageConverter.jpegDataForMetadata(from: imageData)
        let imageURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")

        try jpegData.write(to: imageURL, options: .atomic)
        defer {
            try? FileManager.default.removeItem(at: imageURL)
        }

        guard let pictureRef = TagPictureRef(
            url: imageURL,
            pictureDescription: "Front Cover",
            pictureType: "Front Cover"
        ) else {
            throw NSError(
                domain: "AudioModifier.SPFKMetadataService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Não foi possível preparar a imagem selecionada para gravação."]
            )
        }

        guard TagPicture.write(pictureRef, path: audioURL.path) else {
            throw NSError(
                domain: "AudioModifier.SPFKMetadataService",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Não foi possível salvar a capa no áudio."]
            )
        }
    }

    private func coverImageData(from url: URL) -> Data? {
        #if canImport(AppKit)
        guard let pictureRef = try? TagPictureRef.parsing(url: url) else {
            return nil
        }

        let image = NSImage(cgImage: pictureRef.cgImage, size: .zero)
        return image.tiffRepresentation
        #else
        return nil
        #endif
    }
    #endif
}

private extension String {
    var nilIfBlank: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
