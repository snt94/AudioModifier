//
//  EditableAudioMetadata.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation

/// Modelo usado como rascunho na tela de edição de metadados.
///
/// Ele é separado de `AudioMetadata` por um motivo prático: na UI, `TextField`
/// trabalha melhor com `String` não opcional. Já ao salvar, strings vazias são
/// convertidas para `nil`, removendo ou ignorando a tag correspondente.
struct EditableAudioMetadata: Hashable {
    /// Novo título da música.
    var title: String

    /// Novo artista principal.
    var artist: String

    /// Novo nome do álbum.
    var album: String

    /// Novo artista do álbum.
    var albumArtist: String

    /// Novo gênero musical.
    var genre: String

    /// Nova data ou ano.
    var date: String

    /// Novo número de faixa.
    var trackNumber: String

    /// Novo compositor.
    var composer: String

    /// Novo comentário.
    var comment: String

    /// Dados da capa exibida/editada na interface.
    var coverImageData: Data?

    /// Marca se o usuário escolheu uma nova capa durante a edição.
    ///
    /// Isso evita regravar a capa sem necessidade quando o usuário apenas altera
    /// campos de texto.
    var didChangeCoverImage = false

    /// Cria um rascunho editável a partir dos metadados atuais do arquivo.
    init(metadata: AudioMetadata?) {
        title = metadata?.title ?? ""
        artist = metadata?.artist ?? ""
        album = metadata?.album ?? ""
        albumArtist = metadata?.albumArtist ?? ""
        genre = metadata?.genre ?? ""
        date = metadata?.date ?? ""
        trackNumber = metadata?.trackNumber ?? ""
        composer = metadata?.composer ?? ""
        comment = metadata?.comment ?? ""
        coverImageData = metadata?.coverImageData
    }
}
