//
//  SelectViewModel.swift
//  AudioModifier
//
//  Created by Eduardo Luis on 06/06/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class SelectViewModel {
    var selectedAudioFile: AudioFile?
    var isImporterPresented = false
    var isLoading = false
    var errorMessage: String?
    
    private let audioSelectService: AudioSelectService
    
    init() {
        self.audioSelectService = AudioSelectService()
    }
    
    init(audioSelectService: AudioSelectService) {
        self.audioSelectService = audioSelectService
    }
    
    func handleFileImporterResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            selectAudio(from: url)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    private func selectAudio(from url: URL) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                selectedAudioFile = try await audioSelectService.makeAudioFile(from: url)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}
