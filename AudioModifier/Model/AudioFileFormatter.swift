//
//  AudioFileFormatter.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import Foundation

struct AudioFileFormatter {
    func formatDuration(_ duration: Double) -> String {
        guard duration.isFinite, duration > 0 else {
            return "Desconhecida"
        }
        
        let totalSeconds = Int(duration.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func formatBitrate(_ bitrate: Int) -> String {
        guard bitrate > 0 else {
            return "Desconhecido"
        }
        
        return "\(bitrate / 1_000) kbps"
    }
    
}
