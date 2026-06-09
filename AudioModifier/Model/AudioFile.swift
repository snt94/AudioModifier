//
//  AudioFile.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import Foundation

struct AudioFile: Codable, Hashable {
    let name: String
    let url: URL
    let duration: Double
    let bitrate: Int
    let sampleRate: Double
    let channelCount: Int
    let format: String
    let bitDepth: Int
    let metadata: AudioMetadata?
}
