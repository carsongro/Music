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
            HStack {
                if let artwork = album.artwork {
                    ArtworkImage(artwork, width: 100)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                VStack(alignment: .leading) {
                    if let releaseDate = album.releaseDate?.formatted(date: .abbreviated, time: .omitted) {
                        Text(releaseDate)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(album.title)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
