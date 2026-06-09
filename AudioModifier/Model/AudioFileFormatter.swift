//
//  AudioFileFormatter.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import Foundation

struct AudioFileFormatter {
    func duration(_ value: Double) -> String {
        guard value.isFinite, value > 0 else {
            return "Desconhecida"
        }

        let totalSeconds = Int(value.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%d:%02d", minutes, seconds)
    }

    func bitrate(_ value: Int) -> String {
        guard value > 0 else {
            return "Desconhecido"
        }

        return "\(value / 1_000) kbps"
    }

    func sampleRate(_ value: Double) -> String {
        guard value > 0 else {
            return "Desconhecida"
        }

        let kHz = value / 1_000
        return String(format: "%.1f kHz", kHz)
            .replacingOccurrences(of: ".0 kHz", with: " kHz")
    }

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

    func bitDepth(_ value: Int) -> String {
        guard value > 0 else {
            return "Desconhecido"
        }

        return "\(value) bits"
    }
}
