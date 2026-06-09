//
//  EditMetadataActionBar.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import SwiftUI

/// Barra de ações do editor de metadados.
struct EditMetadataActionBar: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let isSaving: Bool
    let onCancel: () -> Void
    let onSave: () -> Void

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    var body: some View {
        if isCompact {
            VStack(spacing: 10) {
                saveButton
                cancelButton
            }
        } else {
            HStack {
                Spacer()
                cancelButton
                saveButton
            }
        }
    }

    private var cancelButton: some View {
        Button("Cancelar") {
            onCancel()
        }
        .frame(maxWidth: isCompact ? .infinity : nil)
        .disabled(isSaving)
    }

    private var saveButton: some View {
        Button {
            onSave()
        } label: {
            if isSaving {
                ProgressView()
                    .controlSize(.small)
            } else {
                Label("Salvar", systemImage: "checkmark")
            }
        }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: isCompact ? .infinity : nil)
        .disabled(isSaving)
    }
}
