//
//  AlbumDetailView.swift
//  BottomTray
//
//  Created by Carson Gross on 12/21/23.
//

import MusicKit
import SwiftUI

/// `AlbumDetailView` is a view that presents detailed information about a specific `Album`.
struct AlbumDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let album: Album
    @State var tracks: MusicItemCollection<Track>?
    @State var relatedAlbums: MusicItemCollection<Album>?
    
    init(_ album: Album) {
        self.album = album
    }
    
    var body: some View {
        List {
            Section(header: header, content: {})
            
            if let tracks, !tracks.isEmpty {
                Section(header: Text("Tracks")) {
                    ForEach(tracks) { track in
                        TrackCell(track, from: album) {
                            MusicPlayerManager.shared.handleTrackSelected(track, loadedTracks: tracks)
                        }
                    }
                }
            }
            
            if let relatedAlbums, !relatedAlbums.isEmpty {
                Section(header: Text("Related Albums")) {
                    ForEach(relatedAlbums) { album in
                        AlbumCell(album)
                    }
                }
            }
        }
        .navigationTitle(album.title)
        .task {
            RecentAlbumsStorage.shared.update(with: album)
            try? await loadTracksAndRelatedAlbums()
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
    
    private var header: some View {
        VStack {
            if let artwork = album.artwork {
                ArtworkImage(artwork, width: 320)
                    .cornerRadius(8)
            }
            Text(album.artistName)
                .font(.title2.bold())
            playButtonRow
        }
    }
       
    private func loadTracksAndRelatedAlbums() async throws {
        let detailedAlbum = try await album.with([.artists, .tracks])
        let artist = try await detailedAlbum.artists?.first?.with([.albums])
        update(tracks: detailedAlbum.tracks, relatedAlbums: artist?.albums)
    }
    
    @MainActor
    private func update(tracks: MusicItemCollection<Track>?, relatedAlbums: MusicItemCollection<Album>?) {
        withAnimation {
            self.tracks = tracks
            self.relatedAlbums = relatedAlbums
        }
    }
    
    // MARK: - Playback
    
    /// The MusicKit player to use for Apple Music playback.
    private let player = ApplicationMusicPlayer.shared
    
    /// The state of the MusicKit player to use for Apple Music playback.
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    
    /// `true` when the album detail view sets a playback queue on the player.
    @State private var isPlaybackQueueSet = false
    
    private var isPlaying: Bool {
        return (playerState.playbackStatus == .playing)
    }
    
    /// The Apple Music subscription of the current user.
    @State private var musicSubscription: MusicSubscription?
    
    private let playButtonTitle: LocalizedStringKey = "Play"
    private let pauseButtonTitle: LocalizedStringKey = "Pause"
    
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
                MusicPlayerManager.shared.handlePlayButtonSelected(album: album)
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

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
