//
//  CoverImagePreview.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

struct CoverImagePreview: View {
    let imageData: Data?
    var size: CGFloat = 96

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.secondary.opacity(0.12))
                .frame(width: size, height: size)

            if let image = coverImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "music.note")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
        }
    }

    #if canImport(AppKit)
    private var coverImage: NSImage? {
        guard let imageData else {
            return nil
        }

        return NSImage(data: imageData)
    }
    #else
    private var coverImage: NSImage? { nil }
    #endif
}
