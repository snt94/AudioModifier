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

/// ViewModel da tela de edição de metadados.
///
/// Esta classe controla o formulário, a escolha de capa, a confirmação de destino
/// de salvamento e a chamada ao serviço que realmente grava o arquivo.
@MainActor
@Observable
final class EditMetadataViewModel {
    /// Arquivo que está sendo editado.
    let audioFile: AudioFile

    /// Rascunho editável dos metadados.
    var metadata: EditableAudioMetadata

    /// Controla a apresentação do seletor de imagem da capa.
    var isCoverImporterPresented = false

    /// Controla a caixa de confirmação entre salvar no original ou em uma cópia.
    var isSaveConfirmationPresented = false

    /// Indica que uma operação de gravação está em andamento.
    var isSaving = false

    /// Mensagem usada para alertas de erro.
    var errorMessage: String?

    /// Tipos de imagem aceitos para capa.
    let supportedCoverTypes: [UTType] = [.jpeg, .png, .tiff, .heic, .webP]

    /// Serviço compartilhado com a tela de seleção.
    private let audioSelectService: AudioSelectService

    /// Inicializador usado em previews ou quando não é necessário injetar serviço.
    init(audioFile: AudioFile) {
        self.audioFile = audioFile
        self.metadata = EditableAudioMetadata(metadata: audioFile.metadata)
        self.audioSelectService = AudioSelectService()
    }

    /// Inicializador usado pelo fluxo real, reaproveitando o serviço da tela anterior.
    init(audioFile: AudioFile, audioSelectService: AudioSelectService) {
        self.audioFile = audioFile
        self.metadata = EditableAudioMetadata(metadata: audioFile.metadata)
        self.audioSelectService = audioSelectService
    }

    /// Processa o resultado do seletor de imagem.
    func handleCoverImporterResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            loadCoverImage(from: url)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    /// Solicita confirmação do usuário antes de gravar metadados.
    func requestSave() {
        isSaveConfirmationPresented = true
    }

    /// Salva os metadados diretamente no arquivo original.
    func saveToOriginal() async -> AudioFile? {
        await save(destination: .original)
    }

    /// Pergunta onde criar a cópia e salva os metadados nessa cópia.
    func saveToCopy() async -> AudioFile? {
        guard let copyURL = await chooseCopyURL() else {
            return nil
        }

        return await save(destination: .copy(copyURL))
    }

    /// Limpa a mensagem de erro depois do alerta.
    func clearError() {
        errorMessage = nil
    }

    /// Lê a imagem selecionada e converte para dados exibíveis.
    ///
    /// O acesso de segurança é necessário porque a imagem vem de um seletor de
    /// arquivos em app sandboxed no macOS.
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

    /// Executa o salvamento e devolve o arquivo recarregado em caso de sucesso.
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

    /// Mostra um painel nativo do macOS para escolher onde salvar a cópia editada.
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

    /// Sugere um nome para a cópia sem sobrescrever o arquivo original por acidente.
    private var defaultCopyFilename: String {
        let baseName = audioFile.url.deletingPathExtension().lastPathComponent
        let fileExtension = audioFile.url.pathExtension

        guard !fileExtension.isEmpty else {
            return "\(baseName) - editado"
        }

        return "\(baseName) - editado.\(fileExtension)"
    }
}
