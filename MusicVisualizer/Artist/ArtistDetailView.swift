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
    @State private var fullArtist: Artist?
    
    var body: some View {
        Group {
            if let fullArtist {
                List {
                    Section {
                        if let artwork = fullArtist.artwork {
                            ArtworkImage(artwork, width: 150)
                                .clipShape(Circle())
                        }
                        
                        Text(fullArtist.name)
                    }
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity)
                    
                    if let albums = fullArtist.albums {
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(albums) { albums in
                                        AlbumCell(albums)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            } else {
                Color.clear
            }
        }
        .task {
            do {
                fullArtist = try await artist.with([.featuredAlbums, .topSongs, .albums, .latestRelease])
                dump(fullArtist?.featuredAlbums)
            } catch {
                print("Error fetching artist details: \(error.localizedDescription)")
            }
        }
    }
}
