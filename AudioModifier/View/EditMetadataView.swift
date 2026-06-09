//
//  EditMetadataView.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import SwiftUI

/// Sheet de edição dos metadados do arquivo selecionado.
struct EditMetadataView: View {
    @Bindable var viewModel: EditMetadataViewModel
    let onCancel: () -> Void
    let onSave: (AudioFile) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            formContent
            actionBar
        }
        .frame(minWidth: 520, minHeight: 620)
        .padding(24)
        .fileImporter(
            isPresented: $viewModel.isCoverImporterPresented,
            allowedContentTypes: viewModel.supportedCoverTypes,
            onCompletion: viewModel.handleCoverImporterResult
        )
        .confirmationDialog(
            "Como deseja salvar?",
            isPresented: $viewModel.isSaveConfirmationPresented,
            titleVisibility: .visible
        ) {
            saveDestinationButtons
        } message: {
            Text("Você pode gravar diretamente no arquivo selecionado ou criar uma cópia antes de aplicar os metadados.")
        }
        .alert(
            "Não foi possível salvar os metadados",
            isPresented: errorAlertBinding
        ) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "Erro desconhecido.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Editar metadados")
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.audioFile.url.lastPathComponent)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private var formContent: some View {
        @Bindable var viewModel = viewModel

        return Form {
            CoverEditorSection(
                imageData: viewModel.metadata.coverImageData,
                isSaving: viewModel.isSaving,
                onChooseImage: {
                    viewModel.isCoverImporterPresented = true
                }
            )

            MetadataMainFieldsSection(metadata: $viewModel.metadata)
            MetadataDetailsSection(metadata: $viewModel.metadata)
        }
        .formStyle(.grouped)
    }

    private var actionBar: some View {
        EditMetadataActionBar(
            isSaving: viewModel.isSaving,
            onCancel: onCancel,
            onSave: viewModel.requestSave
        )
    }

    @ViewBuilder
    private var saveDestinationButtons: some View {
        Button("Alterar arquivo original", role: .destructive) {
            Task {
                if let updatedAudioFile = await viewModel.saveToOriginal() {
                    onSave(updatedAudioFile)
                }
            }
        }

        Button("Criar cópia modificada") {
            Task {
                if let updatedAudioFile = await viewModel.saveToCopy() {
                    onSave(updatedAudioFile)
                }
            }
        }

        Button("Cancelar", role: .cancel) {}
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding {
            viewModel.errorMessage != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.clearError()
            }
        }
    }
}

#Preview {
    EditMetadataView(
        viewModel: EditMetadataViewModel(
            audioFile: AudioFile(
                name: "Exemplo",
                url: URL(filePath: "/tmp/audio.mp3"),
                duration: 120,
                bitrate: 128_000,
                sampleRate: 44_100,
                channelCount: 2,
                format: "MP3",
                bitDepth: 0,
                metadata: nil
            )
        ),
        onCancel: {},
        onSave: { _ in }
    )
}
