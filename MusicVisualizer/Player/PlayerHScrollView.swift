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
        ScrollViewReader { proxy in
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
                print(newValue)
            }
            .onAppear {
                if let id = MusicPlayerManager.shared.currentSong?.id {
                    withAnimation(.none) {
                        proxy.scrollTo(id)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .onChange(of: MusicPlayerManager.shared.currentSong) { oldValue, newValue in
                if let id = newValue?.id {
                    withAnimation(.bouncy(duration: 0.25, extraBounce: -0.1)) {
                        proxy.scrollTo(id)
                    }
                }
            }
        }
    }
}

#Preview {
    PlayerHScrollView()
}
