//
//  SelectView.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import SwiftUI
import UniformTypeIdentifiers

/// Tela principal para selecionar um áudio, visualizar dados técnicos e abrir o editor de metadados.
struct SelectView: View {
    @State private var viewModel = SelectViewModel()
    private let formatter = AudioFileFormatter()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                selectButton

                if viewModel.isLoading {
                    ProgressView("Carregando áudio...")
                }

                if let audioFile = viewModel.selectedAudioFile {
                    selectedAudioSection(audioFile)
                }
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .fileImporter(
            isPresented: $viewModel.isImporterPresented,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false,
            onCompletion: viewModel.handleFileImporterResult
        )
        .sheet(isPresented: metadataEditorBinding) {
            if let editor = viewModel.metadataEditor {
                EditMetadataView(
                    viewModel: editor,
                    onCancel: {
                        viewModel.finishMetadataEditing(with: nil)
                    },
                    onSave: { audioFile in
                        viewModel.finishMetadataEditing(with: audioFile)
                    }
                )
            }
        }
        .alert(
            "Não foi possível carregar o áudio",
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Selecionar áudio")
                .font(.title)
                .fontWeight(.semibold)

            Text("Escolha um arquivo de áudio para carregar informações técnicas e tags de metadados.")
                .foregroundStyle(.secondary)
        }
    }

    private var selectButton: some View {
        Button {
            viewModel.isImporterPresented = true
        } label: {
            Label("Selecionar arquivo", systemImage: "music.note")
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isLoading)
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

    private var metadataEditorBinding: Binding<Bool> {
        Binding {
            viewModel.metadataEditor != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.finishMetadataEditing(with: nil)
            }
        }
    }

    private func selectedAudioSection(_ audioFile: AudioFile) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            technicalInfoSection(audioFile)
            metadataSection(audioFile.metadata)
        }
    }

    private func technicalInfoSection(_ audioFile: AudioFile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Arquivo selecionado")
                    .font(.headline)

                Spacer()

                Button {
                    viewModel.beginMetadataEditing()
                } label: {
                    Label("Editar metadados", systemImage: "pencil")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
                .help("Editar metadados")
            }

            LabeledContent("Nome", value: audioFile.name)
            LabeledContent("Formato", value: audioFile.format.isEmpty ? "Desconhecido" : audioFile.format)
            LabeledContent("Duração", value: formatter.duration(audioFile.duration))
            LabeledContent("Bitrate", value: formatter.bitrate(audioFile.bitrate))
            LabeledContent("Sample rate", value: formatter.sampleRate(audioFile.sampleRate))
            LabeledContent("Canais", value: formatter.channelCount(audioFile.channelCount))
            LabeledContent("Bit depth", value: formatter.bitDepth(audioFile.bitDepth))
            LabeledContent("Caminho", value: audioFile.url.path)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func metadataSection(_ metadata: AudioMetadata?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Metadados")
                .font(.headline)

            if let metadata, metadata.hasVisibleValues {
                if metadata.coverImageData != nil {
                    CoverImagePreview(imageData: metadata.coverImageData, size: 120)
                }

                metadataRow("Título", metadata.title)
                metadataRow("Artista", metadata.artist)
                metadataRow("Álbum", metadata.album)
                metadataRow("Artista do álbum", metadata.albumArtist)
                metadataRow("Gênero", metadata.genre)
                metadataRow("Data", metadata.date)
                metadataRow("Faixa", metadata.trackNumber)
                metadataRow("Compositor", metadata.composer)
                metadataRow("Comentário", metadata.comment)

                if !metadata.tags.isEmpty {
                    Divider()

                    ForEach(metadata.tags) { tag in
                        LabeledContent(tag.name, value: tag.value)
                    }
                }
            } else {
                Text("Nenhum metadado encontrado. Use o lápis para adicionar informações ao áudio.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func metadataRow(_ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            LabeledContent(label, value: value)
        }
    }
}

#Preview {
    SelectView()
}
