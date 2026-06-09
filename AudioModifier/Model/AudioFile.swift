//
//  AudioFile.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import Foundation

/// Representa um arquivo de áudio já carregado pelo app.
///
/// Este é o principal modelo exibido na `SelectView`. Ele junta dados técnicos
/// lidos com AVFoundation/SPFKMetadata e metadados de música, como título,
/// artista, álbum e capa.
struct AudioFile: Codable, Hashable {
    /// Nome usado na interface. Quando existe título nos metadados, ele é preferido.
    let name: String

    /// Local do arquivo no disco.
    ///
    /// Em apps macOS com sandbox, URLs vindas de seletores de arquivo podem precisar
    /// de `startAccessingSecurityScopedResource()` antes de leitura ou escrita.
    let url: URL

    /// Duração do áudio em segundos.
    let duration: Double

    /// Taxa de bits em bits por segundo. Exemplo: `320_000` representa 320 kbps.
    let bitrate: Int

    /// Frequência de amostragem em Hertz. Exemplo: `44_100` representa 44.1 kHz.
    let sampleRate: Double

    /// Quantidade de canais de áudio. Exemplo: `1` para mono e `2` para estéreo.
    let channelCount: Int

    /// Extensão/formato do arquivo, geralmente `MP3`, `M4A`, `WAV`, etc.
    let format: String

    /// Profundidade de bits por amostra quando disponível.
    ///
    /// Arquivos comprimidos como MP3 frequentemente não informam esse valor.
    let bitDepth: Int

    /// Metadados musicais e tags extras encontrados no arquivo.
    let metadata: AudioMetadata?
}
