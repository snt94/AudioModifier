//
//  AudioTechnicalInfo.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation

/// Agrupa informações técnicas do áudio que não são tags musicais.
///
/// Este tipo existe para separar dados de formato físico do arquivo, como duração,
/// bitrate e sample rate, dos metadados editáveis como título e artista.
struct AudioTechnicalInfo: Codable, Hashable {
    /// Duração em segundos.
    let duration: Double

    /// Taxa de bits em bits por segundo.
    let bitrate: Int

    /// Frequência de amostragem em Hertz.
    let sampleRate: Double

    /// Quantidade de canais do arquivo.
    let channelCount: Int

    /// Profundidade de bits por canal, quando disponível.
    let bitDepth: Int
}
