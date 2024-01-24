//
//  ArtistDetailView.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/23/24.
//

import SwiftUI
import MusicKit

struct ArtistDetailView: View {
    var artist: Artist
    
    var body: some View {
        List {
            Section {
                if let artwork = artist.artwork {
                    ArtworkImage(artwork, width: 150)
                        .clipShape(Circle())
                }
                
                Text(artist.name)
            }
            .listRowSeparator(.hidden)
            .frame(maxWidth: .infinity)
        }
        .listStyle(.plain)
    }
}
