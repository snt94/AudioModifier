//
//  MetadataFieldsSection.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import SwiftUI

struct MetadataMainFieldsSection: View {
    @Binding var metadata: EditableAudioMetadata

    var body: some View {
        Section("Informações principais") {
            TextField("Nome da música", text: $metadata.title)
            TextField("Artista", text: $metadata.artist)
            TextField("Álbum", text: $metadata.album)
            TextField("Artista do álbum", text: $metadata.albumArtist)
        }
    }
}

struct MetadataDetailsSection: View {
    @Binding var metadata: EditableAudioMetadata

    var body: some View {
        Section("Detalhes") {
            TextField("Gênero", text: $metadata.genre)
            TextField("Ano/Data", text: $metadata.date)
            TextField("Número da faixa", text: $metadata.trackNumber)
            TextField("Compositor", text: $metadata.composer)
            TextField("Comentário", text: $metadata.comment, axis: .vertical)
                .lineLimit(3...6)
        }
    }
}
