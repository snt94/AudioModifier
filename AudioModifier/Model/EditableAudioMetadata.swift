//
//  EditableAudioMetadata.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation

struct EditableAudioMetadata: Hashable {
    var title: String
    var artist: String
    var album: String
    var albumArtist: String
    var genre: String
    var date: String
    var trackNumber: String
    var composer: String
    var comment: String
    var coverImageData: Data?
    var didChangeCoverImage = false

    init(metadata: AudioMetadata?) {
        title = metadata?.title ?? ""
        artist = metadata?.artist ?? ""
        album = metadata?.album ?? ""
        albumArtist = metadata?.albumArtist ?? ""
        genre = metadata?.genre ?? ""
        date = metadata?.date ?? ""
        trackNumber = metadata?.trackNumber ?? ""
        composer = metadata?.composer ?? ""
        comment = metadata?.comment ?? ""
        coverImageData = metadata?.coverImageData
    }
}
