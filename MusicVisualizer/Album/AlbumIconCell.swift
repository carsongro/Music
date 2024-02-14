//
//  AlbumIconCell.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/24/24.
//

import SwiftUI
import MusicKit

struct AlbumIconCell: View {
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    var album: Album
    
    init(_ album: Album) {
        self.album = album
    }
    
    var body: some View {
        NavigationLink(value: album) {
            VStack(alignment: .leading) {
                if let artwork = album.artwork {
                    ArtworkImage(artwork, width: prefersTabNavigation ? 170 : 290)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Text(album.title)
                    .lineLimit(1)
            }
            .containerRelativeFrame(
                .horizontal,
                count: 16,
                span: prefersTabNavigation ? 8 : 4,
                spacing: prefersTabNavigation ? 10 : 20
            )
        }
        .buttonStyle(.plain)
    }
}
