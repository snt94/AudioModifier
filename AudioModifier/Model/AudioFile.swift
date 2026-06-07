//
//  AudioFile.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import Foundation

struct AudioFile: Codable {
    let name: String
    let url: URL
    let duration: Double
    let bitrate: Int
    // let sampleRate: Int
    // let channels: Int
    let format: String
    let bitDepth: Int
}
