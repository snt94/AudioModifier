//
//  CoverImageConverter.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation

#if canImport(AppKit)
import AppKit
#endif

/// Converte imagens de capa entre formatos usados pela interface e pela escrita de metadados.
///
/// O usuário pode selecionar imagens comuns como JPG, PNG, TIFF, HEIC ou WebP.
/// A interface precisa apenas de dados que o `NSImage` consiga renderizar, enquanto
/// o TagLib/SPFKMetadata recebe melhor uma imagem preparada como JPEG para gravação.
enum CoverImageConverter {
    /// Valida dados de imagem e devolve uma representação segura para exibir no SwiftUI.
    ///
    /// No macOS, a conversão passa por `NSImage` e `tiffRepresentation`, que normaliza
    /// vários formatos de entrada para uma representação que a prévia consegue carregar.
    static func displayableData(from sourceData: Data) throws -> Data {
        #if canImport(AppKit)
        guard let image = NSImage(data: sourceData), let tiffData = image.tiffRepresentation else {
            throw imageError("Não foi possível reconhecer a imagem selecionada.")
        }

        return tiffData
        #else
        return sourceData
        #endif
    }

    /// Converte a capa para JPEG antes de salvar no arquivo de áudio.
    ///
    /// A escrita de capa passa pelo SPFKMetadata/TagLib. Usar JPEG reduz diferenças
    /// entre formatos de imagem e torna o processo mais previsível.
    static func jpegDataForMetadata(from sourceData: Data) throws -> Data {
        #if canImport(AppKit)
        guard let image = NSImage(data: sourceData),
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.92])
        else {
            throw imageError("Não foi possível converter a imagem selecionada para JPEG.")
        }

        return jpegData
        #else
        return sourceData
        #endif
    }

    /// Cria um erro Foundation simples com uma mensagem amigável para a interface.
    private static func imageError(_ message: String) -> NSError {
        NSError(
            domain: "AudioModifier.CoverImageConverter",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}
