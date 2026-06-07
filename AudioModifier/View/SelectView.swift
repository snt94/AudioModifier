//
//  SelectView.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct SelectView: View {
    @State private var viewModel = SelectViewModel()
    private var formatter = AudioFileFormatter()
    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Selecionar áudio")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Escolha um arquivo de áudio para carregar suas informações básicas.")
                    .foregroundStyle(.secondary)
            }
            
            Button {
                viewModel.isImporterPresented = true
            } label: {
                Label("Selecionar arquivo", systemImage: "music.note")
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView("Carregando áudio...")
            }
            
            if let audioFile = viewModel.selectedAudioFile {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Arquivo selecionado")
                        .font(.headline)
                    
                    LabeledContent("Nome", value: audioFile.name)
                    LabeledContent("Formato", value: audioFile.format.isEmpty ? "Desconhecido" : audioFile.format)
                    LabeledContent("Duração", value: formatter.formatDuration(audioFile.duration))
                    LabeledContent("Bitrate", value: formatter.formatBitrate(audioFile.bitrate))
                    LabeledContent("Bit depth", value: audioFile.bitDepth > 0 ? "\(audioFile.bitDepth) bits" : "Desconhecido")
                    LabeledContent("Caminho", value: audioFile.url.path)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(minWidth: 520, minHeight: 360, alignment: .topLeading)
        .padding(32)
        .fileImporter(
            isPresented: $viewModel.isImporterPresented,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false,
            onCompletion: viewModel.handleFileImporterResult
        )
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
    SelectView()
}
