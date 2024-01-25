//
//  SongGrid.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/25/24.
//

import SwiftUI
import MusicKit

struct SongGrid: View {
    
    let songs: MusicItemCollection<Song>
    let count: Int
    
    private let topSongRows = [
        GridItem(.flexible(minimum: 25, maximum: 55)),
        GridItem(.flexible(minimum: 25, maximum: 55)),
        GridItem(.flexible(minimum: 25, maximum: 55)),
        GridItem(.flexible(minimum: 25, maximum: 55))
    ]
    
    init(_ songs: MusicItemCollection<Song>, count: Int = 8) {
        self.songs = songs
        self.count = count
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: topSongRows) {
                ForEach(songs.prefix(upTo: count)) { song in
                    ArtistSongCell(song) {
                        MusicPlayerManager.shared.handleSongSelected(song)
                    }
                    .containerRelativeFrame(
                        .horizontal,
                        count: 10,
                        span: 9,
                        spacing: 5.0
                    )
                }
                .scrollTargetLayout()
            }
        }
        .scrollTargetBehavior(.paging)
    }
}
