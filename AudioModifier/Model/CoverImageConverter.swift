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

enum CoverImageConverter {
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

    private static func imageError(_ message: String) -> NSError {
        NSError(
            domain: "AudioModifier.CoverImageConverter",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}
