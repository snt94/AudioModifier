//
//  MetadataSaveDestination.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import Foundation

enum MetadataSaveDestination: Hashable {
    case original
    case copy(URL)
}
