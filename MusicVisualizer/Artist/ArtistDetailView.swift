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
        GeometryReader { proxy in
            Group {
                if let fullArtist {
                    List {
                        Section {
                            Header(
                                artist: artist,
                                width: proxy.frame(in: .global).width
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                        .frame(maxWidth: .infinity)
                        
                        if let latestRelease = fullArtist.latestRelease {
                            Section {
                                ArtistLatestReleaseCell(latestRelease)
                            } 
                            .listRowSeparator(.hidden)
                        }
                        
                        if let songs = fullArtist.topSongs {
                            Section {
                                SongGrid(songs)
                            } header: {
                                Text("Top Songs")
                            }
                            .listSectionSeparator(.hidden)
                        }
                        
                        if let albums = fullArtist.albums {
                            Section {
                                AlbumsHScrollView(albums)
                            } header: {
                                Text("Albums")
                            }
                            .listSectionSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .contentMargins(.bottom, 65, for: .scrollContent)
                } else {
                    Color.clear
                }
            }
            .navigationTitle(artist.name)
            .task {
                do {
                    fullArtist = try await artist.with([.featuredAlbums, .topSongs, .albums, .latestRelease])
                } catch {
                    print("Error fetching artist details: \(error.localizedDescription)")
                }
            }
        }
    }
    
    struct Header: View {
        @Environment(\.prefersTabNavigation) private var prefersTabNavigation
        
        let artist: Artist
        let width: CGFloat
        
        private var artworkSize: CGFloat {
            prefersTabNavigation ? width - 30 : width / 2
        }
        
        var body: some View {
            if let artwork = artist.artwork {
                ArtworkImage(
                    artwork,
                    width: artworkSize,
                    height: artworkSize
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}
