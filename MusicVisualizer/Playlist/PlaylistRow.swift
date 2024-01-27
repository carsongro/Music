//
//  PlaylistRow.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/27/24.
//

import SwiftUI
import MusicKit

struct PlaylistRow: View {
    let playlist: Playlist
    
    init(_ playlist: Playlist) {
        self.playlist = playlist
    }
    
    var body: some View {
        NavigationLink(value: playlist.id) {
            MusicItemCell(
                artwork: playlist.artwork,
                title: playlist.name,
                subtitle: playlist.curatorName ?? ""
            )
        }
    }
}
