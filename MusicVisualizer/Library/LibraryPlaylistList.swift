//
//  LibraryPlaylistList.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/27/24.
//

import SwiftUI
import MusicKit

struct LibraryPlaylistList: View {
    @Environment(LibraryModel.self) private var libraryModel
    
    var listedPlaylists: [Playlist] {
        libraryModel.playlists
            .filter { $0.matches(libraryModel.searchText) }
            .sorted(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
    }
    
    var body: some View {
        List(listedPlaylists) { playlist in
            PlaylistRow(playlist)
        }
        .listStyle(.plain)
        .contentMargins(.bottom, 65, for: .scrollContent)
    }
}

extension Playlist {
    func matches(_ string: String) -> Bool {
        string.isEmpty ||
        name.localizedCaseInsensitiveContains(string)
    }
}

#Preview {
    LibraryPlaylistList()
        .environment(LibraryModel())
}
