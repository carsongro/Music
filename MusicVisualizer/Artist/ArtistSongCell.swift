//
//  ArtistSongCell.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/24/24.
//

import SwiftUI
import MusicKit

struct ArtistSongCell: View {
    
    init(_ song: Song, action: @escaping () -> Void) {
        self.song = song
        self.action = action
    }
    
    let song: Song
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let artwork = song.artwork {
                    VStack {
                        Spacer()
                        ArtworkImage(artwork, width: 45)
                            .cornerRadius(6)
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(song.title)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text(song.artistName)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .frame(minHeight: 45)
        }
    }
}
