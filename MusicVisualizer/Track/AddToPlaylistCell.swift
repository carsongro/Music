//
//  AddToPlaylistCell.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 3/5/24.
//

import SwiftUI
import MusicKit

struct AddToPlaylistCell: View {
    @Binding var showingPlaylistPicker: Bool
    let playlist: Playlist
    let selectedTrack: Track?
    
    var body: some View {
        Button(action: addItemToPlaylist) {
            MusicItemCell(
                artwork: playlist.artwork,
                title: playlist.name,
                subtitle: playlist.curatorName ?? ""
            )
        }
    }
    
    private func addItemToPlaylist() {
        Task {
            if let selectedTrack {
                do {
                    try await MusicLibrary.shared.add(selectedTrack, to: playlist)
                } catch {
                    print("Error adding track to playlist: \(error.localizedDescription)")
                }
            }
            showingPlaylistPicker = false
        }
    }
}
