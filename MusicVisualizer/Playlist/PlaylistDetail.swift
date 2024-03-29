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
        .task {
            for await subscription in MusicSubscription.subscriptionUpdates {
                musicSubscription = subscription
            }
        }
        #if canImport(MusicSubscriptionOffer)
        .musicSubscriptionOffer(isPresented: $isShowingSubscriptionOffer, options: subscriptionOfferOptions)
        #endif
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
    
    
    @State private var musicSubscription: MusicSubscription?
    private let playButtonTitle: LocalizedStringKey = "Play"
    
    private var isPlayButtonDisabled: Bool {
        let canPlayCatalogContent = musicSubscription?.canPlayCatalogContent ?? false
        return !canPlayCatalogContent
    }
    
    private var shouldOfferSubscription: Bool {
        let canBecomeSubscriber = musicSubscription?.canBecomeSubscriber ?? false
        return canBecomeSubscriber
    }
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
            .disabled(isPlayButtonDisabled)
            .animation(.easeInOut(duration: 0.1), value: isPlaying)
            
            if shouldOfferSubscription {
                subscriptionOfferButton
            }
        }
    }
    
    // MARK: - Subscription offer
    
    private var subscriptionOfferButton: some View {
        Button(action: handleSubscriptionOfferButtonSelected) {
            HStack {
                Image(systemName: "applelogo")
                Text("Join")
            }
            .frame(maxWidth: 200)
        }
        .buttonStyle(.prominent)
    }
    
    @State private var isShowingSubscriptionOffer = false
    
    #if canImport(MusicSubscriptionOffer)
    @State private var subscriptionOfferOptions: MusicSubscriptionOffer.Options = .default
    #endif
    
    /// Computes the presentation state for a subscription offer.
    private func handleSubscriptionOfferButtonSelected() {
        #if canImport(MusicSubscriptionOffer)
        subscriptionOfferOptions.messageIdentifier = .playMusic
        subscriptionOfferOptions.itemID = album.id
        isShowingSubscriptionOffer = true
        #endif
    }
}
