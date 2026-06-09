//
//  AudioMetadata.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation

/// Contém os metadados musicais que o app entende diretamente.
///
/// Metadados de áudio são informações gravadas dentro do arquivo, como título,
/// artista, álbum e capa. O SPFKMetadata/TagLib pode ler muitas tags diferentes;
/// este modelo separa as mais importantes em propriedades claras e guarda o resto
/// em `tags` para exibição.
struct AudioMetadata: Codable, Hashable {
    /// Nome da música/faixa.
    let title: String?

    /// Artista principal da música.
    let artist: String?

    /// Nome do álbum.
    let album: String?

    /// Artista responsável pelo álbum, que pode ser diferente do artista da faixa.
    let albumArtist: String?

    /// Gênero musical.
    let genre: String?

    /// Data ou ano de lançamento, dependendo de como o arquivo foi marcado.
    let date: String?

    /// Número da faixa dentro do álbum.
    let trackNumber: String?

    /// Compositor da música.
    let composer: String?

    /// Comentário textual armazenado no arquivo.
    let comment: String?

    /// Dados da imagem de capa prontos para exibição na interface.
    let coverImageData: Data?

    /// Tags lidas do arquivo que não estão entre os campos principais acima.
    let tags: [AudioMetadataItem]

    /// Indica se existe algo útil para mostrar na seção de metadados.
    var hasVisibleValues: Bool {
        title != nil || artist != nil || album != nil || albumArtist != nil ||
        genre != nil || date != nil || trackNumber != nil || composer != nil ||
        comment != nil || coverImageData != nil || !tags.isEmpty
    }
}

/// Uma tag extra exibível na interface.
///
/// Use este tipo para tags que existem no arquivo, mas que o app ainda não trata
/// como campo principal editável.
struct AudioMetadataItem: Codable, Hashable, Identifiable {
    /// Nome amigável da tag. Exemplo: `BPM` ou `Copyright`.
    let name: String

    /// Valor textual da tag.
    let value: String

    /// Identificador usado pelo `ForEach` do SwiftUI.
    var id: String {
        "\(name)-\(value)"
    }
}
