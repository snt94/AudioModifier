//
//  EditMetadataViewModel.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation
import Observation
import UniformTypeIdentifiers

#if canImport(AppKit)
import AppKit
#endif

@MainActor
@Observable
final class EditMetadataViewModel {
    let audioFile: AudioFile
    var metadata: EditableAudioMetadata
    var isCoverImporterPresented = false
    var isSaveConfirmationPresented = false
    var isSaving = false
    var errorMessage: String?

    let supportedCoverTypes: [UTType] = [.jpeg, .png, .tiff, .heic, .webP]

    private let audioSelectService: AudioSelectService

    init(audioFile: AudioFile) {
        self.audioFile = audioFile
        self.metadata = EditableAudioMetadata(metadata: audioFile.metadata)
        self.audioSelectService = AudioSelectService()
    }

    init(audioFile: AudioFile, audioSelectService: AudioSelectService) {
        self.audioFile = audioFile
        self.metadata = EditableAudioMetadata(metadata: audioFile.metadata)
        self.audioSelectService = audioSelectService
    }

    func handleCoverImporterResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            loadCoverImage(from: url)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    func requestSave() {
        isSaveConfirmationPresented = true
    }

    func saveToOriginal() async -> AudioFile? {
        await save(destination: .original)
    }

    func saveToCopy() async -> AudioFile? {
        guard let copyURL = await chooseCopyURL() else {
            return nil
        }

        return await save(destination: .copy(copyURL))
    }

    func clearError() {
        errorMessage = nil
    }

    private func loadCoverImage(from url: URL) {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let sourceData = try Data(contentsOf: url)
            metadata.coverImageData = try CoverImageConverter.displayableData(from: sourceData)
            metadata.didChangeCoverImage = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save(destination: MetadataSaveDestination) async -> AudioFile? {
        isSaving = true
        errorMessage = nil

        do {
            let updatedAudioFile = try await audioSelectService.saveMetadata(
                metadata,
                from: audioFile.url,
                destination: destination
            )
            isSaving = false
            return updatedAudioFile
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
            return nil
        }
    }

    private func chooseCopyURL() async -> URL? {
        #if canImport(AppKit)
        let panel = NSSavePanel()
        panel.title = "Salvar cópia modificada"
        panel.nameFieldStringValue = defaultCopyFilename
        panel.canCreateDirectories = true
        panel.directoryURL = audioFile.url.deletingLastPathComponent()

        return await withCheckedContinuation { continuation in
            panel.begin { response in
                continuation.resume(returning: response == .OK ? panel.url : nil)
            }
        }
        #else
        return nil
        #endif
    }

    private var defaultCopyFilename: String {
        let baseName = audioFile.url.deletingPathExtension().lastPathComponent
        let fileExtension = audioFile.url.pathExtension

        guard !fileExtension.isEmpty else {
            return "\(baseName) - editado"
        }

        return "\(baseName) - editado.\(fileExtension)"
    }
}
