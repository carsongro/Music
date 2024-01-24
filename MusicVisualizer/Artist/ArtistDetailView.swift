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
    
    let rows = [
        GridItem(.fixed(80)),
        GridItem(.fixed(80)),
        GridItem(.fixed(80)),
        GridItem(.fixed(80))
    ]
    
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
                    .listSectionSeparator(.hidden)
                    .frame(maxWidth: .infinity)
                    
                    if let songs = fullArtist.topSongs {
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: rows) {
                                    ForEach(songs.prefix(upTo: 8)) { song in
                                        SongCell(song) {
                                            MusicPlayerManager.shared.handleSongSelected(song)
                                        }
                                        .containerRelativeFrame(
                                            .horizontal,
                                            count: 4,
                                            span: 3,
                                            spacing: 10.0
                                        )
                                    }
                                    .scrollTargetLayout()
                                }
                            }
                            .scrollTargetBehavior(.paging)
                        }
                        .listSectionSeparator(.hidden)
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
            } catch {
                print("Error fetching artist details: \(error.localizedDescription)")
            }
        }
    }
}
