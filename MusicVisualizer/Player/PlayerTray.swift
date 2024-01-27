//
//  PlayerTray.swift
//  BottomTray
//
//  Created by Carson Gross on 12/21/23.
//

import MusicKit
import SwiftUI

struct PlayerTray: View {
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    private let player = ApplicationMusicPlayer.shared
    
    var body: some View {
        HStack {
            HStack {
                Group {
                    if let artwork = player.queue.currentEntry?.artwork {
                        ArtworkImage(artwork, width: 45)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .frame(minWidth: 40, minHeight: 40)
                
                Text(player.queue.currentEntry?.title ?? "Nothing is playing")
                    .lineLimit(1)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack {
                    Button {
                        MusicPlayerManager.shared.handlePlayPause()
                    } label: {
                        Image(systemName: playerState.playbackStatus == .playing ? "pause.fill" : "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 14)
                    .frame(width: 30, height: 30)
                    
                    Button {
                        MusicPlayerManager.shared.handleSkipToNext()
                    } label: {
                        Image(systemName: "forward.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
                }
            }
            .frame(minHeight: 45)
            .padding(8)
        }
        .background(.ultraThinMaterial)
    }
}
