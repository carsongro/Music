//
//  MusicPlayerManager.swift
//  BottomTray
//
//  Created by Carson Gross on 12/21/23.
//

import MusicKit
import SwiftUI
import Combine

@Observable final class MusicPlayerManager {
    static let shared = MusicPlayerManager()
    
    private init() { 
        queueObservser = ApplicationMusicPlayer.shared.queue.objectWillChange.sink { [weak self] _ in
            self?.updateCurrentTrackData()
        }
    }
    
    var currentPlaybackTime: TimeInterval = 0.0
    var currentDuration: TimeInterval?
    
    var album: Album?
    /// The MusicKit player to use for Apple Music playback.
    private let player = ApplicationMusicPlayer.shared
    
    /// The state of the MusicKit player to use for Apple Music playback.
    private var playerState = ApplicationMusicPlayer.shared.state
    
    /// `true` when the album detail view sets a playback queue on the player.
    public private(set) var isPlaybackQueueSet = false
    
    private var queueObservser: AnyCancellable?
    
    private var isPlaying: Bool {
        playerState.playbackStatus == .playing
    }
    
    func handlePlayPause() {
        guard isPlaybackQueueSet else { return }
        if isPlaying {
            player.pause()
        } else {
            Task {
                do {
                    try await player.play()
                    updateCurrentTrackData()
                } catch {
                    print("Failed to resume playing with error: \(error).")
                }
            }
        }
    }
    
    func handleSkipToPrevious() {
        guard isPlaybackQueueSet else { return }
        if isPlaying {
            Task {
                do {
                    try await player.skipToPreviousEntry()
                    updateCurrentTrackData()
                } catch {
                    print("Failed to skip to next entry")
                }
            }
        } else {
            Task {
                do {
                    try await player.skipToPreviousEntry()
                    try await player.play()
                    updateCurrentTrackData()
                } catch {
                    print("Failed to skip to next entry")
                }
            }
        }
    }
    
    func handleSkipToNext() {
        guard isPlaybackQueueSet else { return }
        if isPlaying {
            Task {
                do {
                    try await player.skipToNextEntry()
                } catch {
                    print("Failed to skip to next entry")
                }
            }
        } else {
            Task {
                do {
                    try await player.skipToNextEntry()
                    try await player.play()
                } catch {
                    print("Failed to skip to next entry")
                }
            }
        }
    }
    
    func handlePlayButtonSelected(album: Album) {
        if album != self.album {
            isPlaybackQueueSet = false
        }
        
        self.album = album
        player.queue = [album]
        isPlaybackQueueSet = true
        beginPlaying()
    }
    
    /// The action to perform when the user taps a track in the list of tracks.
    func handleTrackSelected(_ track: Track, loadedTracks: MusicItemCollection<Track>) {
        player.queue = ApplicationMusicPlayer.Queue(for: loadedTracks, startingAt: track)
        isPlaybackQueueSet = true
        beginPlaying()
    }
    
    func handleSongSelected(_ song: Song) {
        player.queue = ApplicationMusicPlayer.Queue(for: [song], startingAt: song)
        isPlaybackQueueSet = true
        beginPlaying()
    }
    
    @MainActor
    func setPlaybackTime(_ newTime: TimeInterval) {
        player.playbackTime = newTime
        updateCurrentTrackData()
    }
    
    /// A convenience method for beginning music playback.
    ///
    /// Call this instead of `MusicPlayer`’s `play()`
    /// method whenever the playback queue is reset.
    private func beginPlaying() {
        updateCurrentTrackData()
        Task {
            do {
                try await player.play()
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
        }
    }
    
    func updateCurrentTrackData() {
        Task { @MainActor in
            currentPlaybackTime = player.playbackTime
            if let id = player.queue.currentEntry?.item?.id,
               let song = await getSong(id) {
                currentDuration = song.duration
            }
        }
    }
    
    private func getSong(_ id: MusicItemID) async -> Song? {
        let songRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: id)
        let songResponse = try? await songRequest.response()
        guard let song = songResponse?.items.first(where: { $0.id == id }) else {
            return nil
        }
        return song
    }
}
