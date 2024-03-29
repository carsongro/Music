//
//  PlayerHScrollView.swift
//  MusicVisualizer
//
//  Created by Carson Gross on 3/14/24.
//

import SwiftUI
import MusicKit

struct PlayerHScrollView: View {
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    private let player = ApplicationMusicPlayer.shared
    
    @State private var entryID: MusicPlayer.Queue.Entry.Item.ID?
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(player.queue.entries) { entry in
                    if let artwork = entry.artwork {
                        PlayerArtworkView(artwork: artwork, isLarge: playerState.playbackStatus == .playing)
                            .id(entry.item?.id)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $entryID)
        .onChange(of: entryID) { oldValue, newValue in
            print("HI")
        }
        .onAppear {
            if let id = MusicPlayerManager.shared.currentSong?.id {
                entryID = id
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .onChange(of: MusicPlayerManager.shared.currentSong) { oldValue, newValue in
            entryID = newValue?.id
        }
    }
}

#Preview {
    PlayerHScrollView()
}
