//
//  SongCell.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/23/24.
//

import MusicKit
import SwiftUI

/// `SongCell` is a view to use in a SwiftUI `List` to represent a `Song`.
struct SongCell: View {
    
    init(_ song: Song, action: @escaping () -> Void) {
        self.song = song
        self.action = action
    }
    
    let song: Song
    let action: () -> Void
    
    private var subtitle: String {
        "Song · " + song.artistName
    }
    
    var body: some View {
        Button(action: action) {
            MusicItemCell(
                artwork: song.artwork,
                title: song.title,
                subtitle: subtitle
            )
            .frame(minHeight: 50)
        }
    }
}
