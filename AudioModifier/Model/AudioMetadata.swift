//
//  AudioMetadata.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation

struct AudioMetadata: Codable, Hashable {
    let title: String?
    let artist: String?
    let album: String?
    let albumArtist: String?
    let genre: String?
    let date: String?
    let trackNumber: String?
    let composer: String?
    let comment: String?
    let coverImageData: Data?
    let tags: [AudioMetadataItem]

    var hasVisibleValues: Bool {
        title != nil || artist != nil || album != nil || albumArtist != nil ||
        genre != nil || date != nil || trackNumber != nil || composer != nil ||
        comment != nil || coverImageData != nil || !tags.isEmpty
    }
}

struct AudioMetadataItem: Codable, Hashable, Identifiable {
    let name: String
    let value: String

    var id: String {
        "\(name)-\(value)"
    }
}
