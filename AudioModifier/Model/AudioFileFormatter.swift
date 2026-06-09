//
//  AudioFileFormatter.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import Foundation

/// Formata valores técnicos de áudio para textos amigáveis na interface.
///
/// Manter essa lógica fora das Views evita repetir conversões como segundos para
/// `mm:ss` ou Hertz para kHz em vários lugares do app.
struct AudioFileFormatter {
    /// Converte segundos em um texto no formato `minutos:segundos`.
    func duration(_ value: Double) -> String {
        guard value.isFinite, value > 0 else {
            return "Desconhecida"
        }

        let totalSeconds = Int(value.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Converte bits por segundo para kbps.
    func bitrate(_ value: Int) -> String {
        guard value > 0 else {
            return "Desconhecido"
        }

        return "\(value / 1_000) kbps"
    }

    /// Converte Hertz para kHz.
    func sampleRate(_ value: Double) -> String {
        guard value > 0 else {
            return "Desconhecida"
        }

        let kHz = value / 1_000
        return String(format: "%.1f kHz", kHz)
            .replacingOccurrences(of: ".0 kHz", with: " kHz")
    }

    /// Mostra a quantidade de canais com nomes comuns quando possível.
    func channelCount(_ value: Int) -> String {
        switch value {
        case 1:
            return "Mono"
        case 2:
            return "Stereo"
        case 3...:
            return "\(value) canais"
        default:
            return "Desconhecido"
        }
    }

    /// Formata a profundidade de bits.
    func bitDepth(_ value: Int) -> String {
        guard value > 0 else {
            return "Desconhecido"
        }

        return "\(value) bits"
    }
}
