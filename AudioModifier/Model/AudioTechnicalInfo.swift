//
//  AudioTechnicalInfo.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation

struct AudioTechnicalInfo: Codable, Hashable {
    let duration: Double
    let bitrate: Int
    let sampleRate: Double
    let channelCount: Int
    let bitDepth: Int
}
