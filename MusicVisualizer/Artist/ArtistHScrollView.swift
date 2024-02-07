//
//  ArtistHScrollView.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 2/7/24.
//

import SwiftUI
import MusicKit

struct ArtistHScrollView: View {
    let artists: MusicItemCollection<Artist>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(artists) { artist in
                    ArtistCellSmall(artist: artist)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .never))
    }
}
