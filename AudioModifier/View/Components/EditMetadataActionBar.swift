//
//  EditMetadataActionBar.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import SwiftUI

struct EditMetadataActionBar: View {
    let isSaving: Bool
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack {
            Spacer()

            Button("Cancelar") {
                onCancel()
            }
            .disabled(isSaving)

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
            .disabled(isSaving)
        }
    }
}
