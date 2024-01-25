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
                            ArtworkImage(artwork, width: 175)
                                .clipShape(Circle())
                        }

                    }
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                    .frame(maxWidth: .infinity)
                    
                    if let songs = fullArtist.topSongs {
                        Section {
                            SongGrid(songs)
                        } header: {
                            Text("Top Songs")
                        }
                        .listSectionSeparator(.hidden)
                    }
                    
                    if let latestRelease = fullArtist.latestRelease {
                        Section {
                            ArtistLatestReleaseCell(latestRelease)
                        } header: {
                            Text("Latest Release")
                        }
                        .listRowSeparator(.hidden)
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
