//
//  SelectViewModel.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import Foundation
import Observation

/// ViewModel da tela inicial de seleção de áudio.
///
/// Em MVVM, a ViewModel guarda o estado da tela e chama serviços. A `SelectView`
/// apenas mostra esse estado e dispara ações do usuário, como abrir o seletor de
/// arquivos ou começar a editar metadados.
@MainActor
@Observable
final class SelectViewModel {
    /// Arquivo de áudio atualmente selecionado e exibido na tela.
    var selectedAudioFile: AudioFile?

    /// ViewModel do editor. Quando não é `nil`, a `SelectView` apresenta uma sheet.
    var metadataEditor: EditMetadataViewModel?

    /// Controla a apresentação do `fileImporter` de áudio.
    var isImporterPresented = false

    /// Indica que o app está carregando dados do arquivo selecionado.
    var isLoading = false

    /// Mensagem exibida em alertas quando algo falha.
    var errorMessage: String?

    /// Serviço que lê arquivos e salva metadados.
    private let audioSelectService: AudioSelectService

    /// Inicializador usado pela tela real do app.
    init() {
        self.audioSelectService = AudioSelectService()
    }

    /// Inicializador útil para testes ou previews com serviço customizado.
    init(audioSelectService: AudioSelectService) {
        self.audioSelectService = audioSelectService
    }

    /// Recebe o resultado do `fileImporter` da `SelectView`.
    ///
    /// O `fileImporter` devolve um `Result`: sucesso com URLs selecionadas ou erro.
    /// Como o app aceita apenas um arquivo, usamos o primeiro URL da lista.
    func handleFileImporterResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            selectAudio(from: url)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    /// Cria a ViewModel do editor de metadados para o arquivo selecionado.
    func beginMetadataEditing() {
        guard let selectedAudioFile else { return }
        metadataEditor = EditMetadataViewModel(
            audioFile: selectedAudioFile,
            audioSelectService: audioSelectService
        )
    }

    /// Fecha o editor e, se uma edição foi salva, atualiza o arquivo exibido.
    func finishMetadataEditing(with audioFile: AudioFile?) {
        if let audioFile {
            selectedAudioFile = audioFile
        }

        metadataEditor = nil
    }

    /// Limpa a mensagem de erro depois que o usuário fecha o alerta.
    func clearError() {
        errorMessage = nil
    }

    /// Carrega o arquivo de áudio em uma `Task` para não bloquear a interface.
    private func selectAudio(from url: URL) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                selectedAudioFile = try await audioSelectService.makeAudioFile(from: url)
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
