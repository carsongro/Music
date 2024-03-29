//
//  PlaylistDetail.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 1/27/24.
//

import SwiftUI
import MusicKit

struct PlaylistDetail: View {
    @Environment(LibraryModel.self) private var libraryModel
    let playlist: Playlist
    @State private var detailedPlaylist: Playlist?
    @State private var showingPlaylistPicker = false
    
    private var isPlaying: Bool {
        return (ApplicationMusicPlayer.shared.state.playbackStatus == .playing)
    }
    
    init(_ playlist: Playlist) {
        self.playlist = playlist
    }
    
    var body: some View {
        Group {
            if let detailedPlaylist {
                List {
                    Section { } header: { header }
                    
                    if let tracks = detailedPlaylist.tracks {
                        Section {
                            ForEach(tracks.sorted(by: { $0.libraryAddedDate ?? Date.now > $1.libraryAddedDate ?? Date.now })) { track in
                                Button {
                                    MusicPlayerManager.shared.handleTrackSelected(
                                        track,
                                        loadedTracks: tracks
                                    )
                                } label: {
                                    MusicItemCell(
                                        artwork: track.artwork,
                                        title: track.title,
                                        subtitle: track.artistName
                                    )
                                    .frame(minHeight: 50)
                                    .contextMenu {
                                        Button("Add to playlist", systemImage: "plus") {
                                            showingPlaylistPicker = true
                                        }
                                    }
                                    .sheet(isPresented: $showingPlaylistPicker) {
                                        Task {
                                            await getDetailedPlaylist()
                                        }
                                    } content:  {
                                        PlaylistAddToPlaylistView(
                                            showingPlaylistPicker: $showingPlaylistPicker,
                                            selectedTrack: track
                                        )
                                        .environment(libraryModel)
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    if let moreByCurator = detailedPlaylist.moreByCurator, !moreByCurator.isEmpty {
                        Section {
                            ForEach(moreByCurator) { playlist in
                                PlaylistRow(playlist)
                            }
                        } header: {
                            Text("More By " + (detailedPlaylist.curatorName ?? "Curator"))
                        }
                    }
                    
                    if let featuredArtists = detailedPlaylist.featuredArtists {
                        Section {
                            ArtistHScrollView(artists: featuredArtists)
                        } header: {
                            Text("Featured Artists")
                        }
                        .listRowBackground(Color(.systemGroupedBackground))
                    }
                }
                .navigationTitle(playlist.name)
                .contentMargins(.bottom, 65, for: .scrollContent)
            } else {
                Color.clear
            }
        }
        .task {
            await getDetailedPlaylist()
        }
        .canOfferSubscription(for: playlist.id, messageIdentifier: .playMusic, disableContent: false)
    }
    
    private func getDetailedPlaylist() async {
        do {
            detailedPlaylist = try await playlist.with([.tracks, .moreByCurator, .featuredArtists])
        } catch {
            print("Error fetching detailed playlist: \(error.localizedDescription)")
        }
    }
    
    @ViewBuilder
    private var header: some View {
        VStack {
            if let artwork = playlist.artwork {
                ArtworkImage(artwork, width: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            playButtonRow
        }
    }
    
    private let playButtonTitle: LocalizedStringKey = "Play"
    
    /// A declaration of the Play/Pause button, and (if appropriate) the Join button, side by side.
    private var playButtonRow: some View {
        HStack {
            Button {
                if let detailedPlaylist {
                    MusicPlayerManager.shared.handlePlayButtonSelected(playlist: detailedPlaylist)
                }
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text(playButtonTitle)
                }
                .frame(maxWidth: 200)
            }
            .buttonStyle(.prominent)
            .animation(.easeInOut(duration: 0.1), value: isPlaying)
        }
        .canOfferSubscription(for: playlist.id, messageIdentifier: .playMusic, disableContent: true)
    }
}
