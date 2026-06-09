//
//  CoverEditorSection.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import SwiftUI

/// Seção do formulário usada para visualizar e trocar a capa.
struct CoverEditorSection: View {
    let imageData: Data?
    let isSaving: Bool
    let onChooseImage: () -> Void

    var body: some View {
        Section("Capa") {
            HStack(spacing: 16) {
                CoverImagePreview(imageData: imageData)

                Button {
                    onChooseImage()
                } label: {
                    Label("Escolher imagem", systemImage: "photo")
                }
                .disabled(isSaving)
            }
            .padding(.vertical, 4)
        }
    }
}
