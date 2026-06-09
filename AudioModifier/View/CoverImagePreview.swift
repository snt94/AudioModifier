//
//  CoverImagePreview.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 09/06/26.
//

import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Prévia reutilizável da capa do áudio.
struct CoverImagePreview: View {
    let imageData: Data?
    var size: CGFloat = 96

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.secondary.opacity(0.12))
                .frame(width: size, height: size)

            coverContent
        }
    }

    @ViewBuilder
    private var coverContent: some View {
        #if canImport(AppKit)
        if let imageData, let image = NSImage(data: imageData) {
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            placeholder
        }
        #elseif canImport(UIKit)
        if let imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            placeholder
        }
        #else
        placeholder
        #endif
    }

    private var placeholder: some View {
        Image(systemName: "music.note")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
    }
}
