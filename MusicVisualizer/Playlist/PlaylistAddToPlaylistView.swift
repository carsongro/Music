//
//  PlaylistAddToPlaylistView.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 3/5/24.
//

import SwiftUI
import MusicKit

struct PlaylistAddToPlaylistView: View {
    @Environment(LibraryModel.self) private var libraryModel
    
    @Binding var showingPlaylistPicker: Bool
    let selectedTrack: Track
    
    var body: some View {
        List(libraryModel.playlists) { playlist in
            AddToPlaylistCell(
                showingPlaylistPicker: $showingPlaylistPicker,
                playlist: playlist,
                selectedTrack: selectedTrack
            )
        }
        .listStyle(.plain)
        .contentMargins(.bottom, 65, for: .scrollContent)
    }
}
