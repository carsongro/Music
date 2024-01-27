//
//  LibraryNavigationStack.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/24/24.
//

import SwiftUI
import MusicKit

struct LibraryNavigationStack: View {
    @State private var libraryModel = LibraryModel()
    
    var body: some View {
        @Bindable var libraryModel = libraryModel
        
        NavigationStack {
            LibraryPlaylistList()
                .environment(libraryModel)
                .navigationTitle("Library")
                .navigationDestination(for: Playlist.ID.self) { id in
                    if let playlist = libraryModel.playlists.first(where: { $0.id == id }) {
                        PlaylistDetail(playlist)
                    }
                }
                .searchable(text: $libraryModel.searchText)
        }
    }
}

#Preview {
    LibraryNavigationStack()
}
