//
//  AudioService.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import AVFoundation
import Foundation

/// Serviço de alto nível para carregar e salvar arquivos de áudio.
///
/// Na arquitetura MVVM deste projeto, a ViewModel chama este serviço em vez de
/// acessar AVFoundation ou SPFKMetadata diretamente. Isso deixa as telas mais
/// simples e concentra as regras de leitura/escrita de arquivos em um só lugar.
struct AudioSelectService {
    /// Serviço especializado em metadados/tags de áudio.
    private let metadataService: SPFKMetadataService

    /// Permite injetar outro serviço em testes ou no futuro.
    init(metadataService: SPFKMetadataService = SPFKMetadataService()) {
        self.metadataService = metadataService
    }

    /// Carrega um arquivo escolhido pelo usuário e devolve um `AudioFile` pronto para a UI.
    ///
    /// O macOS sandbox pode exigir acesso de segurança para URLs escolhidas em um
    /// `fileImporter`, por isso o método usa `startAccessingSecurityScopedResource()`.
    func makeAudioFile(from url: URL) async throws -> AudioFile {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        return try await loadAudioFile(from: url)
    }

    /// Salva metadados no arquivo original ou em uma cópia, dependendo do destino escolhido.
    ///
    /// - Parameters:
    ///   - metadata: Rascunho editável vindo da tela `EditMetadataView`.
    ///   - sourceURL: Arquivo de áudio originalmente selecionado pelo usuário.
    ///   - destination: Define se a escrita será no original ou em uma cópia.
    /// - Returns: O arquivo recarregado depois da escrita, já refletindo as novas tags.
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

    /// Decide qual URL será escrita.
    ///
    /// No modo `.copy`, o arquivo é copiado antes da escrita. Se a gravação falhar,
    /// o original permanece intacto.
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

    /// Lê dados técnicos e metadados do arquivo e monta o modelo usado pela interface.
    ///
    /// O SPFKMetadata é preferido quando consegue ler propriedades técnicas, mas
    /// AVFoundation entra como fallback para dados como duração e formato de áudio.
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

    /// Usa AVFoundation para extrair informações técnicas básicas.
    ///
    /// `AVURLAsset` carrega propriedades de mídia de forma assíncrona. Isso evita
    /// travar a interface enquanto o sistema analisa o arquivo.
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

    /// Estima bitrate quando a biblioteca não informa esse valor diretamente.
    private static func estimatedBitrate(fileSizeInBytes: Double?, durationInSeconds: Double) -> Int {
        guard let fileSizeInBytes, durationInSeconds > 0 else {
            return 0
        }

        return Int((fileSizeInBytes * 8) / durationInSeconds)
    }
}

/// Ajuda a combinar dados vindos de duas fontes diferentes.
///
/// Se o SPFKMetadata retornar `0` para algum campo técnico, este fallback usa o
/// valor correspondente extraído com AVFoundation.
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
