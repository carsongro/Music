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
        let artist: Artist
        let width: CGFloat
        
        var body: some View {
            if let artwork = artist.artwork {
                ArtworkImage(
                    artwork,
                    width: width - 30,
                    height: width * 0.6
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}
