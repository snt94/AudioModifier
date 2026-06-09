//
//  CoverEditorSection.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import SwiftUI

/// Seção do formulário usada para visualizar e trocar a capa.
struct CoverEditorSection: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let imageData: Data?
    let isSaving: Bool
    let onChooseImage: () -> Void

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    var body: some View {
        Section("Capa") {
            if isCompact {
                VStack(alignment: .leading, spacing: 12) {
                    CoverImagePreview(imageData: imageData, size: 112)
                    chooseImageButton
                }
                .padding(.vertical, 4)
            } else {
                HStack(spacing: 16) {
                    CoverImagePreview(imageData: imageData)
                    chooseImageButton
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var chooseImageButton: some View {
        Button {
            onChooseImage()
        } label: {
            Label("Escolher imagem", systemImage: "photo")
                .frame(maxWidth: isCompact ? .infinity : nil)
        }
        .disabled(isSaving)
    }
}
