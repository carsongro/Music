//
//  ArtistLatestReleaseCell.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/25/24.
//

import SwiftUI
import MusicKit

struct ArtistLatestReleaseCell: View {
    var album: Album
    
    init(_ album: Album) {
        self.album = album
    }
    
    var body: some View {
        NavigationLink(value: album) {
            VStack(alignment: .leading) {
                if let artwork = album.artwork {
                    ArtworkImage(artwork, width: 300)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Text(album.title)
                    .lineLimit(1)
                    .frame(width: 300)
            }
        }
        .buttonStyle(.plain)
    }
}
